// testdll.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"

extern "C" __declspec(dllexport)int suma(int A, int B);

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