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

typedef unsigned long (*fp_FotoNBioAPI_Init) ();
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_CheckValidity)();
typedef int (*fp_FotoNBioAPI_InitLog) ();
typedef int (*fp_FotoNBioAPI_ShutdownLog) ();
typedef const char* (*fp_FotoNBioAPI_EnumerateDevice) (NBioAPI_HANDLE g_hBSP);
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_OpenDevice) (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID);
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_CloseDevice) (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID);

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
		fp_FotoNBioAPI_InitLog FotoNBioAPI_InitLog;
		FotoNBioAPI_InitLog = (fp_FotoNBioAPI_InitLog) GetProcAddress(hinstLib, "FotoNBioAPI_InitLog");
		if (FotoNBioAPI_InitLog == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		int res = FotoNBioAPI_InitLog();
		if (res==0)
			cout << "InitLog OK\n";
		else
			cout << "InitLog Error\n";

		// Get function pointer
		fp_FotoNBioAPI_CheckValidity FotoNBioAPI_CheckValidity;
		FotoNBioAPI_CheckValidity = (fp_FotoNBioAPI_CheckValidity) GetProcAddress(hinstLib, "FotoNBioAPI_CheckValidity");
		if (FotoNBioAPI_CheckValidity == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}

		cout << "Llamado a la funcion FotoNBioAPI_CheckValidity\n";
		NBioAPI_RETURN ret = FotoNBioAPI_CheckValidity();

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
		dll_handle = (unsigned long) FotoNBioAPI_Init();

		// Get function pointer
		fp_FotoNBioAPI_EnumerateDevice FotoNBioAPI_EnumerateDevice;
		FotoNBioAPI_EnumerateDevice = (fp_FotoNBioAPI_EnumerateDevice) GetProcAddress(hinstLib, "FotoNBioAPI_EnumerateDevice");
		if (FotoNBioAPI_EnumerateDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		cout << "Found devices: " << FotoNBioAPI_EnumerateDevice(dll_handle) << "\n";

		
		// Get function pointer
		fp_FotoNBioAPI_OpenDevice FotoNBioAPI_OpenDevice;
		FotoNBioAPI_OpenDevice = (fp_FotoNBioAPI_OpenDevice) GetProcAddress(hinstLib, "FotoNBioAPI_OpenDevice");
		if (FotoNBioAPI_OpenDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		if (FotoNBioAPI_OpenDevice(dll_handle,NBioAPI_DEVICE_NAME_FDU01)==NBioAPIERROR_NONE)
			cout << "Device initialized\n";
		else
			cout << "Device could not be initialized!\n";

		// Get function pointer
		fp_FotoNBioAPI_CloseDevice FotoNBioAPI_CloseDevice;
		FotoNBioAPI_CloseDevice = (fp_FotoNBioAPI_CloseDevice) GetProcAddress(hinstLib, "FotoNBioAPI_CloseDevice");
		if (FotoNBioAPI_CloseDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		if (FotoNBioAPI_CloseDevice(dll_handle,NBioAPI_DEVICE_NAME_FDU01)==NBioAPIERROR_NONE)
			cout << "Device closed\n";
		else
			cout << "Device could not be closed!\n";

		// Get function pointer
		fp_FotoNBioAPI_ShutdownLog FotoNBioAPI_ShutdownLog;
		FotoNBioAPI_ShutdownLog = (fp_FotoNBioAPI_ShutdownLog) GetProcAddress(hinstLib, "FotoNBioAPI_ShutdownLog");
		if (FotoNBioAPI_ShutdownLog == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		res = FotoNBioAPI_ShutdownLog();
		if (res==0)
			cout << "ShutdownLog OK\n";
		else
			cout << "ShutdownLog Error\n";

		cout << "Presione ENTER para finalizar...\n" << endl;

		getchar();

		// Unload DLL file
		FreeLibrary(hinstLib);
		
		nRetCode = 0;
	}

	return nRetCode;
}
