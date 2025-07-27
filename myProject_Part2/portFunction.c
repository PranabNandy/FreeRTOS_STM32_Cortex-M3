#include <stddef.h>  // for size_t

void* memset(void *dst, int value, unsigned int size) {
    unsigned char *ptr = (unsigned char *)dst;
    unsigned char byte_value = (unsigned char)value;

    // Fill memory byte by byte
    while (size > 0) {
        *ptr = byte_value;
        ptr++;
        size--;
    }

    return dst;  // Return original pointer as per standard
}
