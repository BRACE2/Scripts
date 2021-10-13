#include <ctype.h>
#include "jansson.h"

struct scrape_Config {
  const char *google_map_api_key;
  const char *user_agent;
  int verbosity;
  FILE *errfile;
  FILE *outfile;
};

/* Allocate memory and create a formatted string. */
char *scrape_mkstr(const char *fmt, ...);

/* Send a request to `url` using curl */
json_t *scrape_req_json(const char *url, struct scrape_Config *config);

/* Return an address located at coordinates lat,lng using the Google maps
 * api
 */
char *scrape_req_address(double lat, double lng, struct scrape_Config *config);

