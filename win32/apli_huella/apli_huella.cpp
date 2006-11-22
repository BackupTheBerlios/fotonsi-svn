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
#include "NBioAPI_Type.h"
#include "NBioAPI_CheckValidity.h"

typedef void (*fp_FotoNBioAPI_Init) ();
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_CheckFinger) ();
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_Terminate)();
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_CheckValidity)();
typedef int (*fp_FotoNBioAPI_InitLog) ();
typedef int (*fp_FotoNBioAPI_ShutdownLog) ();
typedef const char* (*fp_FotoNBioAPI_EnumerateDevice) ();
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_OpenDevice) (NBioAPI_DEVICE_ID nDeviceID);
typedef NBioAPI_RETURN (*fp_FotoNBioAPI_CloseDevice) (NBioAPI_DEVICE_ID nDeviceID);
typedef NBioAPI_DEVICE_INFO_0* (*fp_FotoNBioAPI_GetDeviceInfo)  (NBioAPI_DEVICE_ID nDeviceID);
typedef const char* (*fp_FotoNBioAPI_Enroll)();
typedef BOOL (*fp_FotoNBioAPI_Verify) (const char* plantilla);

// prueba_juan
typedef NBioAPI_RETURN (*fp_NBioAPI_OpenDevice) (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID);

int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
	int nRetCode = 0;
	unsigned long dll_handle;

	int nRetCode2 = 0;
	unsigned long dll_handle2;

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
		FotoNBioAPI_Init();

		/*
		// prueba_juan
		// Load DLL file
		HINSTANCE hinstLib2 = LoadLibrary("NBioBSP.DLL");
		if (hinstLib2 == NULL) {
				printf("ERROR: unable to load DLL\n");
				return 1;
		}
		FP_NBioAPI_Init            fp_NBioAPI_Init;
		fp_NBioAPI_Init = (FP_NBioAPI_Init) GetProcAddress(hinstLib2, "NBioAPI_Init");
		//NBioAPI_OpenDevice = (fp_NBioAPI_OpenDevice) GetProcAddress(hinstLib2, "NBioAPI_OpenDevice");
		if (fp_NBioAPI_Init == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		fp_NBioAPI_Init(&dll_handle2);

		FP_NBioAPI_OpenDevice            fp_NBioAPI_OpenDevice;
		fp_NBioAPI_OpenDevice = (FP_NBioAPI_OpenDevice) GetProcAddress(hinstLib2, "NBioAPI_OpenDevice");
		//NBioAPI_OpenDevice = (fp_NBioAPI_OpenDevice) GetProcAddress(hinstLib2, "NBioAPI_OpenDevice");
		if (fp_NBioAPI_OpenDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		NBioAPI_RETURN ret2 = fp_NBioAPI_OpenDevice(dll_handle2,NBioAPI_DEVICE_NAME_FDU01);
		
		// la otra prueba
		FP_NBioAPI_GetDeviceInfo         fp_NBioAPI_GetDeviceInfo;
		fp_NBioAPI_GetDeviceInfo = (FP_NBioAPI_GetDeviceInfo) GetProcAddress(hinstLib2, "NBioAPI_GetDeviceInfo");

		NBioAPI_DEVICE_INFO_0 Device_info0;
		memset(&Device_info0, 0, sizeof(Device_info0));
		//NBioAPI_DEVICE_INFO_PTR pDeviceInfo = &DeviceInfo;
		//NBioAPI_DEVICE_INFO_PTR pDeviceInfo = NULL;
		ret2 = fp_NBioAPI_GetDeviceInfo (dll_handle2, NBioAPI_DEVICE_NAME_FDU01, 0, &Device_info0);
		*/

		// Get function pointer
		fp_FotoNBioAPI_EnumerateDevice            FotoNBioAPI_EnumerateDevice;
		FotoNBioAPI_EnumerateDevice = (fp_FotoNBioAPI_EnumerateDevice) GetProcAddress(hinstLib, "FotoNBioAPI_EnumerateDevice");
		if (FotoNBioAPI_EnumerateDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		cout << "Found devices: " << FotoNBioAPI_EnumerateDevice() << "\n";
		
		// Get function pointer
		fp_FotoNBioAPI_OpenDevice FotoNBioAPI_OpenDevice;
		FotoNBioAPI_OpenDevice = (fp_FotoNBioAPI_OpenDevice) GetProcAddress(hinstLib, "FotoNBioAPI_OpenDevice");
		if (FotoNBioAPI_OpenDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		if (FotoNBioAPI_OpenDevice(NBioAPI_DEVICE_NAME_FDU01)==NBioAPIERROR_NONE)
			cout << "Device initialized\n";
		else
			cout << "Device could not be initialized!\n";

		// Get function pointer
		fp_FotoNBioAPI_GetDeviceInfo FotoNBioAPI_GetDeviceInfo;
		FotoNBioAPI_GetDeviceInfo = (fp_FotoNBioAPI_GetDeviceInfo) GetProcAddress(hinstLib, "FotoNBioAPI_GetDeviceInfo");
		if (FotoNBioAPI_GetDeviceInfo == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		
		NBioAPI_DEVICE_INFO_0* Device_info0 = NULL;
		Device_info0 = FotoNBioAPI_GetDeviceInfo(NBioAPI_DEVICE_NAME_FDU01);

		// Get function pointer
		fp_FotoNBioAPI_CheckFinger FotoNBioAPI_CheckFinger;
		FotoNBioAPI_CheckFinger = (fp_FotoNBioAPI_CheckFinger) GetProcAddress(hinstLib, "FotoNBioAPI_CheckFinger");
		if (FotoNBioAPI_CheckFinger == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		for (int i=0;i<10000000;i++)
		{
			res = FotoNBioAPI_CheckFinger();
			/*
			if (res)
			{
				cout << "Dedito al canto\n";
				break;
			}
			*/
			if (res==NBioAPIERROR_LOWVERSION_DRIVER)
			{
				cout << "NBioAPIERROR_LOWVERSION_DRIVER\n";
				cout << "La version del driver no soporta esta llamada\n";
				break;
			}
			else
			{
				cout << "No hay dedo\n";
			}
			Sleep(100);
		}
		
		cout << "Dedo?\n";

		// Get function pointer
		fp_FotoNBioAPI_Enroll FotoNBioAPI_Enroll;
		FotoNBioAPI_Enroll = (fp_FotoNBioAPI_Enroll) GetProcAddress(hinstLib, "FotoNBioAPI_Enroll");
		if (FotoNBioAPI_Enroll == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		char* mierda;
		mierda = (char*) FotoNBioAPI_Enroll();

		char resultado[1000];
		memset(resultado,0,1000*sizeof(char));
		strcpy(resultado,mierda);

		// Get function pointer
		fp_FotoNBioAPI_Verify FotoNBioAPI_Verify;
		FotoNBioAPI_Verify = (fp_FotoNBioAPI_Verify) GetProcAddress(hinstLib, "FotoNBioAPI_Verify");
		if (FotoNBioAPI_Verify == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		BOOL validado = FotoNBioAPI_Verify(mierda);

		// Get function pointer
		fp_FotoNBioAPI_CloseDevice FotoNBioAPI_CloseDevice;
		FotoNBioAPI_CloseDevice = (fp_FotoNBioAPI_CloseDevice) GetProcAddress(hinstLib, "FotoNBioAPI_CloseDevice");
		if (FotoNBioAPI_CloseDevice == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		if (FotoNBioAPI_CloseDevice(NBioAPI_DEVICE_NAME_FDU01)==NBioAPIERROR_NONE)
			cout << "Device closed\n";
		else
			cout << "Device could not be closed!\n";

		// Get function pointer
		fp_FotoNBioAPI_Terminate FotoNBioAPI_Terminate;
		FotoNBioAPI_Terminate = (fp_FotoNBioAPI_Terminate) GetProcAddress(hinstLib, "FotoNBioAPI_Terminate");
		if (FotoNBioAPI_Terminate == NULL) {
				printf("ERROR: unable to find DLL function\n");
				return 1;
		}
		res = FotoNBioAPI_Terminate();
		if (res==0)
			cout << "Terminate OK\n";
		else
			cout << "Terminate Error\n";
		
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
