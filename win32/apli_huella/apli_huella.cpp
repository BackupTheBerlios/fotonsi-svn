// apli_huella.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "apli_huella.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// The one and only application object

CWinApp theApp;

using namespace std;

#include "NBioAPI.h"
#include "NBioAPI_CheckValidity.h"

typedef unsigned long (*fp_FotoNBioAPI_Init) (void);
typedef NBioAPI_RETURN (*importFunction_LPCTSTR)(LPCTSTR a);

int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
	int nRetCode = 0;
	unsigned long dll_handle;

	// initialize MFC and print and error on failure
	if (!AfxWinInit(::GetModuleHandle(NULL), NULL, ::GetCommandLine(), 0))
	{
		// TODO: change error code to suit your needs
		_tprintf(_T("Fatal Error: MFC initialization failed\n"));
		nRetCode = 1;
	}
	else
	{

		// Load DLL file
		HINSTANCE hinstLib = LoadLibrary("huella.dll");
		if (hinstLib == NULL) {
				printf("ERROR: unable to load DLL\n");
				return 1;
		}


		// Get function pointer
		importFunction_LPCTSTR FotoNBioAPI_CheckValidity;
		FotoNBioAPI_CheckValidity = (importFunction_LPCTSTR) GetProcAddress(hinstLib, "FotoNBioAPI_CheckValidity");
		if (FotoNBioAPI_CheckValidity == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}

		cout << "Llamado a la funcion FotoNBioAPI_CheckValidity\n";
		NBioAPI_RETURN ret = FotoNBioAPI_CheckValidity((LPCTSTR)"NBioBSP.dll");

		if (ret == NBioAPIERROR_NONE)
			cout << "DLL OK\n";
		else
			cout << "ERROR\n";

		// Get function pointer
		fp_FotoNBioAPI_Init FotoNBioAPI_Init;
		FotoNBioAPI_Init = (fp_FotoNBioAPI_Init) GetProcAddress(hinstLib, "FotoNBioAPI_Init");
		if (FotoNBioAPI_Init == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		dll_handle = (unsigned long) fp_FotoNBioAPI_Init();

		cout << "Presione ENTER para finalizar...\n" << endl;

		getchar();

		// Unload DLL file
		FreeLibrary(hinstLib);
		
		nRetCode = 0;
	}

	return nRetCode;
}
