/* claudio perez
 * July 2021
 */
#include <ctype.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <jansson.h>

#include "scrapeutils.h"
#include "strutils.h"

#define PRGM_NAME "miami"

int
miami_req_folio(char *folio_dst, const char *address,
                struct scrape_Config *config) {
  int status = -1;

  /* replace spaces in address with '+' */
  if (strlen(address) > 1023) {
    fprintf(config->errfile, "Address is too long\n");
    return -1;
  }
  char c, encoded_address[1024], *d = encoded_address;
  while ((c = *address++))
    *d++ = isspace(c) ? '+' : c;

  char *request_url = sutil_mkstr("https://www.miamidade.gov/Apps/PA/"
                                  "PApublicServiceProxy/PaServicesProxy.ashx"
                                  "?Operation=GetAddress"
                                  "&clientAppName=PropertySearch"
                                  "&from=1"
                                  "&myAddress=%s"
                                  "&myUnit="
                                  "&to=200",
                                  encoded_address);

  json_t *obj = scrape_req_json(request_url, config);
  free(request_url);

  if (!obj)
    return -1;

  json_t *base_info = json_object_get(obj, "MinimumPropertyInfos");
  json_t *folio = json_object_get(json_array_get(base_info, 0), "Strap");

  if (folio == NULL) {
    fprintf(config->errfile, "Response error: Unable to get folio number\n");
  } else {
    const char *folio_str = json_string_value(folio);
    sutil_rm(folio_str, folio_dst, '-');
    status = 1;
  }
  // TODO: decref(obj)
  return status;
}

/* Send a request to the Miami-Dade property search server
 * and return a JSON object corresponding to the folio
 * number supplied */
json_t *
miami_req_data(const char *folio, struct scrape_Config *config) {
  char *request_url;
  request_url = sutil_mkstr("https://www.miamidade.gov/Apps/PA/"
                            "PApublicServiceProxy/PaServicesProxy.ashx"
                            "?Operation=GetPropertySearchByFolio"
                            "&clientAppName=PropertySearch"
                            "&folioNumber=%s",
                            folio);
  json_t *data = scrape_req_json(request_url, config);
  free(request_url);
  return data;
}

/********************************************************
 * Command line
 ********************************************************/
void
miami_print_use(void) {
  puts("usage: " PRGM_NAME " OPTIONS\n\n"
       "Scrape the Miami Dade Property Search tool\n\n"
       "Options\n"
       "-a ADDRESS\n"
       "-l LAT,LNG\n"
       "-q\t\tSuppress informative output.\n"
       "-h/--help\tPrint this message and exit."
       "\n");
}

int
main(int argc, char **argv) {
  FILE *outfile = stdout;
  char *address;
  bool free_address = false;

  struct scrape_Config config = {
      .google_map_api_key = getenv("GoogleMapsAPIkey"),
      .verbosity = 0,
      .errfile = stderr,
      .outfile = stdout,
      .user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 "
                    "Firefox/89.0"};

  if (argc < 2) {
    miami_print_use();
    return -1;
  }

  for (int i = 1; i < argc && (argv[i][0] == '-'); i++) {
    if (strcmp(argv[i], "-l") == 0) {
      if (argc == i + 1) {
        puts("ERROR (CLI Parse): Option '-l' requires an argument");
        return -1;
      }
      double lat, lng;
      sscanf(argv[++i], "%lf,%lf", &lat, &lng);
      fprintf(outfile, "%s\t", argv[i]);
      address = scrape_req_address(lat, lng, &config);

      if (!address) {
        fprintf(config.errfile, "Address search failed\n");
        fprintf(outfile, "\n");
        return -1;
      }

      free_address = true;

    } else if ((strcmp(argv[i], "-a") == 0) ||
               (strcmp(argv[i], "--address") == 0)) {
      if (argc == i + 1) {
        puts("ERROR (CLI Parse): Option '-a/--address' requires an argument");
        return -1;
      }
      address = argv[++i];

    } else if (strcmp(argv[i], "-v") == 0) {
      config.verbosity++;

    } else if (strcmp(argv[i], "-q") == 0) {
      config.verbosity = 0;

    } else if ((strcmp(argv[i], "-h") == 0) ||
               (strcmp(argv[i], "--help") == 0)) {
      miami_print_use();
      return 0;

    } else {
      printf(
          "Unrecognized option '%s'; run '%s --help' for available options\n",
          argv[i], PRGM_NAME);
      return -1;
    }
  }



  // fprintf(outfile, "(Lat,Lng)?\tAddress\tFolio Number\tLand use\tFloor
  // Count\tYear built\n");
  fprintf(outfile, "%s\t", address);

  char folio[13 + 1];
  if (miami_req_folio(folio, address, &config) < 0) {
    fprintf(outfile, "\n");
    return -1;
  }

  json_t *data = miami_req_data(folio, &config);

  fprintf(outfile, "%s\t", folio);

  /* Occupancy */
  json_t *DOR =
      json_object_get(json_object_get(data, "PropertyInfo"), "DORDescription");
  fprintf(outfile, "%s\t", json_string_value(DOR));

  /* Floor count */
  json_t *floors =
      json_object_get(json_object_get(data, "PropertyInfo"), "FloorCount");
  fprintf(outfile, "%" JSON_INTEGER_FORMAT "\t", json_integer_value(floors));

  /* Year built */
  json_t *mods = json_object_get(json_object_get(data, "ExtraFeature"),
                                 "ExtraFeatureInfos");

  fprintf(outfile, "%" JSON_INTEGER_FORMAT "\t",
          json_integer_value(
              json_object_get(json_array_get(mods, 0), "ActualYearBuilt")));

  fprintf(outfile, "\n");

  /* Free resources */
  json_decref(data);
  if (free_address)
    free(address);

  return 0;
}
