#ifndef _UART_H
#define _UART_H

#include "types.h"
#include <stdarg.h>
// uart is mapped in UART0
// for further informations regarding the memory mapping see qemu memory tree
#define UART0 0x10000000L
static char digits[] = "0123456789abcdef";
static void panic(char *s);
#define WRITE_UART(c) (*(char *) UART0 = c)

static void print_int(int xx, int base, int sign)
{
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;

  i = 0;
  do {
    buf[i++] = digits[x % base];
  } while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
    WRITE_UART(buf[i]);
}

static void print_ptr(uint64 x)
{
  int i;
  WRITE_UART('0');
  WRITE_UART('x');
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    WRITE_UART(digits[x >> (sizeof(uint64) * 8 - 4)]);
}



static void printf(char *fmt, ...)
{
  va_list ap;
  int i, c;
  char *s;

  if (fmt == 0)
    panic("null fmt");

  va_start(ap, fmt);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    if(c != '%'){
      WRITE_UART(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      print_int(va_arg(ap, int), 10, 1);
      break;
    case 'x':
      print_int(va_arg(ap, int), 16, 1);
      break;
    case 'p':
      print_ptr(va_arg(ap, uint64));
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        WRITE_UART(*s);
      break;
    case '%':
      WRITE_UART('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      WRITE_UART('%');
      WRITE_UART(c);
      break;
    }
  }
}

static void panic(char *s)
{
  printf("panic: ");
  printf(s);
  printf("\n");
  for(;;)
    ;
}

#endif
