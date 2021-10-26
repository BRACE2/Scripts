/*
 * claudio perez
 * July 2021
 * NHERI-SimCenter
 *
 */

/* Standard library */
#include <ctype.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* Copy from read_head to write_head, removing
 * occurances of char `c` */
static void
sutil_rm(const char *read_head, char *write_head, char c) {
  while (*read_head) {
    *write_head = *read_head++;
    write_head += (*write_head != c);
  }
  *write_head = '\0';
}

static char *
sutil_clean(const char *str)
{
  size_t l2 = 0;
  for (int i=0; i < strlen(str); i++) 
    if (isalnum(str[i]) || str[i]==' ') l2++;
  
  char *s2, *p;
  s2 = p = malloc(l2*sizeof(char) + 1);

  while (*p = *str++)
    if (isalnum(*p) || *p==' ') p++;

  return s2;
}

/* This function returns a pointer to a substring of the original string.
 * If the given string was allocated dynamically, the caller must not overwrite
 * that pointer with the returned value.
 */
static char *
sutil_strip(char *str) {
  char *end;
  /* Trim leading space */
  while (isspace((unsigned char)*str))
    str++;

  if (*str == 0)
    return str;

  /* Trim trailing space */
  end = str + strlen(str) - 1;
  while (end > str && isspace((unsigned char)*end))
    end--;

  end[1] = '\0';

  return str;
}

/* Allocate memory and create a formatted string.
 * This function was derived from the man page for the glibc
 * implementation of `snprintf` and friends.
 *
 * The string returned by this function must be freed.
 */
static char *
sutil_mkstr(const char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  int n = vsnprintf(NULL, 0, fmt, ap);
  va_end(ap);

  if (n < 0)
    return NULL;

  size_t size = (size_t)n + 1;
  char *new_str = malloc(size);
  if (new_str == NULL)
    return NULL;

  va_start(ap, fmt);
  n = vsnprintf(new_str, size, fmt, ap);
  va_end(ap);

  if (n < 0) {
    free(new_str);
    return NULL;
  }
  return new_str;
}

