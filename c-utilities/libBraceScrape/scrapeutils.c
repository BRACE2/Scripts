/*
 * claudio perez
 * July 2021
 *
 */

/* Standard library */
#include <ctype.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Dependencies */
#include <curl/curl.h>
#include <jansson.h>

#include "scrapeutils.h"
#include "strutils.h"




/**********************************************************
 * cURL functions
 **********************************************************/
struct scrape_MemoryBlock {
  char *memory;
  size_t size;
};

static size_t
curl_callback(void *contents, size_t size, size_t nmemb, void *userp) {
  size_t realsize = size * nmemb;
  struct scrape_MemoryBlock *blk = (struct scrape_MemoryBlock *)userp;

  char *ptr = realloc(blk->memory, blk->size + realsize + 1);
  if (!ptr) {
    fprintf(stderr, "ERROR (Memory): realloc returned NULL\n");
    return 0;
  }

  blk->memory = ptr;
  memcpy(&(blk->memory[blk->size]), contents, realsize);
  blk->size += realsize;
  blk->memory[blk->size] = 0;
  return realsize;
}

json_t *
scrape_req_json(const char *url, struct scrape_Config *config) {
  json_t *response;
  CURL *curl_handle;
  CURLcode res;

  if (config->verbosity)
    fprintf(config->errfile, "INFO: Requesting URL '%s'\n", url);

  struct scrape_MemoryBlock blk = {.memory = malloc(1), .size = 0};

  curl_global_init(CURL_GLOBAL_ALL);
  curl_handle = curl_easy_init();

  curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, curl_callback);
  curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&blk);
  curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, config->user_agent);

  curl_easy_setopt(curl_handle, CURLOPT_URL, url);
  res = curl_easy_perform(curl_handle);

  if (res != CURLE_OK) {
    fprintf(config->errfile,
            "ERROR (Request): curl failed with message '%s'\n\n",
            curl_easy_strerror(res));
    fprintf(config->errfile, "'%s'\n", url);
    response = NULL;
    goto clean_curl;
  } else {
    char *content_type = NULL;
    curl_easy_getinfo(curl_handle, CURLINFO_CONTENT_TYPE, &content_type);
    if (!res && content_type) {
      if (strncmp(content_type, "application/json", 16) != 0)
        fprintf(config->errfile, "Curl got content type '%s'\n", content_type);
    }
  }

  json_error_t jsonerr;
  response = json_loadb(blk.memory, blk.size, JSON_ALLOW_NUL, &jsonerr);
  if (!response) {
    fprintf(config->errfile, "ERROR (JSON Parse): %s.\n", jsonerr.text);
    if (config->verbosity) {
      fprintf(config->errfile,
              "Error occured while parsing the following response: \n");
      fwrite(blk.memory, sizeof(char), blk.size, config->errfile);
    }
  }

clean_curl:
  /* wrap up curl */
  free(blk.memory);
  curl_easy_cleanup(curl_handle);
  curl_global_cleanup();
  return response;
}

/* Call the Google Maps API to return an address given
 * latitude/longitude coordinates.
 * Returns a new heap-allocated string which must be freed */
char *
scrape_req_address(double lat, double lng, struct scrape_Config *config) {
  static const size_t address_size = 512;
  char *url = scrape_mkstr("https://maps.googleapis.com/maps/api/geocode/json"
                           "?latlng=%lf,%lf"
                           "&key=%s",
                           lat, lng, config->google_map_api_key);
  if (url == NULL)
    return NULL;

  json_t *resp = scrape_req_json(url, config);
  if (!resp)
    return NULL;
  json_t *obj = json_array_get(json_object_get(resp, "results"), 0);
  json_t *adr = json_object_get(obj, "formatted_address");

  int i = 0;
  const char *str = json_string_value(adr);
  char *address = malloc(sizeof(char) * address_size);
  // copy out the address so we can free the JSON object
  strcpy(address, str);
  strtok(address, ",");
  address = sutil_clean(address);
  free(url);
  json_decref(resp);
  return address;
}

