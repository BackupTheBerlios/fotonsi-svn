// testdll.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"

/* test_struct */
typedef struct test_struct {
	UINT32      f;  
	UINT32      e;   
	UINT32      d;    
	UINT32      c;
	UINT32      b;
	UINT32      a;
} TEST_STRUCT;

extern "C" __declspec(dllexport)int suma(int A, int B);
extern "C" __declspec(dllexport)TEST_STRUCT test(UINT32 a, UINT32 b, UINT32 c, UINT32 d, UINT32 e, UINT32 f);

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    return TRUE;
}

int suma(int A, int B)
{
    return A+B;
}

TEST_STRUCT test(UINT32 a, UINT32 b, UINT32 c, UINT32 d, UINT32 e, UINT32 f)
{
	TEST_STRUCT st;
	st.a=a;
	st.b=b;
	st.c=c;
	st.d=d;
	st.e=e;
	st.f=f;
    return st;
}