#include <limits.h>
void foo(){
    int a=INT_MAX;
    while(a){
        a--;
    }
	return;
}
void myStartFunction(){
        int a=INT_MAX;
        while(a){
            a--;

        }
         foo();
		return;
}
