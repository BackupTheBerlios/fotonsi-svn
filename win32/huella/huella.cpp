// huella.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    return TRUE;
}

#include <stdio.h>
#include "NBioAPI.h"
#include "FotoNBioAPI.h"
#include "NBioAPI_CheckValidity.h"
#include <iostream.h>

extern "C" __declspec(dllexport)unsigned long FotoNBioAPI_Init();
extern "C" __declspec(dllexport)int FotoNBioAPI_InitLog();
extern "C" __declspec(dllexport)int FotoNBioAPI_ShutdownLog();
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_CheckValidity();
extern "C" __declspec(dllexport) const char* FotoNBioAPI_EnumerateDevice(NBioAPI_HANDLE g_hBSP);
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_OpenDevice (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID);
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_CloseDevice    (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID);
extern "C" __declspec(dllexport)NBioAPI_DEVICE_INFO_0* FotoNBioAPI_GetDeviceInfo  (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID);

// variables globales que vamos a usar
static NBioAPI_HANDLE m_hBSP;
static NBioAPI_FIR_FORMAT m_nFIRFormat;
static DWORD m_dErrorNum;
static NBioAPI_DEVICE_INFO_0 Device_info0;
static FILE *stream;

// punteros a funciones que cargaremos en memoria al inicializar la DLL
// Init/Terminate Function   
static FP_NBioAPI_Init                  fp_NBioAPI_Init;
static FP_NBioAPI_Terminate             fp_NBioAPI_Terminate;

// Basic Functions
static FP_NBioAPI_GetVersion            fp_NBioAPI_GetVersion;
static FP_NBioAPI_GetInitInfo           fp_NBioAPI_GetInitInfo;
static FP_NBioAPI_SetInitInfo           fp_NBioAPI_SetInitInfo;

// Device Functions
static FP_NBioAPI_EnumerateDevice       fp_NBioAPI_EnumerateDevice;
static FP_NBioAPI_OpenDevice            fp_NBioAPI_OpenDevice;
static FP_NBioAPI_CloseDevice           fp_NBioAPI_CloseDevice;
static FP_NBioAPI_GetDeviceInfo         fp_NBioAPI_GetDeviceInfo;
static FP_NBioAPI_SetDeviceInfo         fp_NBioAPI_SetDeviceInfo;
static FP_NBioAPI_AdjustDevice          fp_NBioAPI_AdjustDevice;

//Memory Functions
static FP_NBioAPI_FreeFIRHandle         fp_NBioAPI_FreeFIRHandle;
static FP_NBioAPI_GetFIRFromHandle      fp_NBioAPI_GetFIRFromHandle;
static FP_NBioAPI_GetHeaderFromHandle   fp_NBioAPI_GetHeaderFromHandle;
static FP_NBioAPI_FreeFIR               fp_NBioAPI_FreeFIR;
static FP_NBioAPI_FreePayload           fp_NBioAPI_FreePayload;

// TextEncode Funtions
static FP_NBioAPI_GetTextFIRFromHandle  fp_NBioAPI_GetTextFIRFromHandle;
static FP_NBioAPI_FreeTextFIR           fp_NBioAPI_FreeTextFIR;

// Extened Functions
static FP_NBioAPI_GetExtendedFIRFromHandle       fp_NBioAPI_GetExtendedFIRFromHandle;
static FP_NBioAPI_GetExtendedHeaderFromHandle    fp_NBioAPI_GetExtendedHeaderFromHandle;
static FP_NBioAPI_GetExtendedTextFIRFromHandle   fp_NBioAPI_GetExtendedTextFIRFromHandle;

// BSP Functions
static FP_NBioAPI_Capture               fp_NBioAPI_Capture;
static FP_NBioAPI_Process               fp_NBioAPI_Process;
static FP_NBioAPI_CreateTemplate        fp_NBioAPI_CreateTemplate;
static FP_NBioAPI_VerifyMatch           fp_NBioAPI_VerifyMatch;
static FP_NBioAPI_Enroll                fp_NBioAPI_Enroll;
static FP_NBioAPI_Verify                fp_NBioAPI_Verify;

// Skin Function
static FP_NBioAPI_SetSkinResource       fp_NBioAPI_SetSkinResource;

// escribe un mensaje debug en el fichero de traza
int debug_message (const char* buf)
{
	if (stream==NULL)
		return -1;
	else
		return fprintf(stream,buf);
}

// abre el fichero de log para poder escribir
int FotoNBioAPI_InitLog()
{
	/* Open for write */
	if( (stream  = fopen( "trace.log", "w+" )) == NULL )
	{
		printf( "The file 'trace.log' was not opened\n" );
		return -1;
	}
	else
		printf( "The file 'trace.log' was opened\n" );

	fprintf(stream,"LogInit\n");
	return 0;
}

// cierra el fichero de log
int FotoNBioAPI_ShutdownLog()
{
	/* Close stream */
	if( fclose( stream ) )
	{
		printf( "The file 'trace.log' was not closed\n" );
		return -1;
	}
	return 0;
}

// inicializa esta DLL y la original, cargando las funciones en memoria
unsigned long FotoNBioAPI_Init()
{
	//FotoNBioAPI_InitLog();
	debug_message("FotoNBioAPI_Init called\n");
	//FotoNBioAPI_ShutdownLog();
	//return 5;

	//return 1;
	HINSTANCE m_hLib;

	m_hLib = 0;
	m_hLib = LoadLibrary("NBioBSP.DLL");
   
    m_dErrorNum = 0;

    if ( !m_hLib )
    {
		debug_message("LoadLibrary failed !!!\n");
		return 0;
    }

	// Basic Functions
	fp_NBioAPI_Init = (FP_NBioAPI_Init) GetProcAddress(m_hLib, "NBioAPI_Init");
	fp_NBioAPI_Terminate = (FP_NBioAPI_Terminate) GetProcAddress(m_hLib, "NBioAPI_Terminate");
	fp_NBioAPI_GetVersion = (FP_NBioAPI_GetVersion) GetProcAddress(m_hLib, "NBioAPI_GetVersion");
	fp_NBioAPI_GetInitInfo = (FP_NBioAPI_GetInitInfo) GetProcAddress(m_hLib, "NBioAPI_GetInitInfo");
	fp_NBioAPI_SetInitInfo = (FP_NBioAPI_SetInitInfo) GetProcAddress(m_hLib, "NBioAPI_SetInitInfo");

	// Device Functions
	fp_NBioAPI_EnumerateDevice = (FP_NBioAPI_EnumerateDevice) GetProcAddress(m_hLib, "NBioAPI_EnumerateDevice");
	fp_NBioAPI_OpenDevice = (FP_NBioAPI_OpenDevice) GetProcAddress(m_hLib, "NBioAPI_OpenDevice");
	fp_NBioAPI_CloseDevice = (FP_NBioAPI_CloseDevice) GetProcAddress(m_hLib, "NBioAPI_CloseDevice");
	fp_NBioAPI_GetDeviceInfo = (FP_NBioAPI_GetDeviceInfo) GetProcAddress(m_hLib, "NBioAPI_GetDeviceInfo");
	fp_NBioAPI_SetDeviceInfo = (FP_NBioAPI_SetDeviceInfo) GetProcAddress(m_hLib, "NBioAPI_SetDeviceInfo");
	fp_NBioAPI_AdjustDevice = (FP_NBioAPI_AdjustDevice) GetProcAddress(m_hLib, "NBioAPI_AdjustDevice");

	//Memory Functions
	fp_NBioAPI_FreeFIRHandle = (FP_NBioAPI_FreeFIRHandle) GetProcAddress(m_hLib, "NBioAPI_FreeFIRHandle");
	fp_NBioAPI_GetFIRFromHandle = (FP_NBioAPI_GetFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetFIRFromHandle");
	fp_NBioAPI_GetHeaderFromHandle = (FP_NBioAPI_GetHeaderFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetHeaderFromHandle");
	fp_NBioAPI_FreeFIR = (FP_NBioAPI_FreeFIR) GetProcAddress(m_hLib, "NBioAPI_FreeFIR");
	fp_NBioAPI_FreePayload = (FP_NBioAPI_FreePayload) GetProcAddress(m_hLib, "NBioAPI_FreePayload");

	// TextEncode Funtions
	fp_NBioAPI_GetTextFIRFromHandle = (FP_NBioAPI_GetTextFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetTextFIRFromHandle");
	fp_NBioAPI_FreeTextFIR = (FP_NBioAPI_FreeTextFIR) GetProcAddress(m_hLib, "NBioAPI_FreeTextFIR");

	// Extened Functions
	fp_NBioAPI_GetExtendedFIRFromHandle = (FP_NBioAPI_GetExtendedFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetExtendedFIRFromHandle");
	fp_NBioAPI_GetExtendedHeaderFromHandle = (FP_NBioAPI_GetExtendedHeaderFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetExtendedHeaderFromHandle");
	fp_NBioAPI_GetExtendedTextFIRFromHandle = (FP_NBioAPI_GetExtendedTextFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetExtendedTextFIRFromHandle");

	// BSP Functions
	fp_NBioAPI_Capture = (FP_NBioAPI_Capture) GetProcAddress(m_hLib, "NBioAPI_Capture");
	fp_NBioAPI_Process = (FP_NBioAPI_Process) GetProcAddress(m_hLib, "NBioAPI_Process");
	fp_NBioAPI_CreateTemplate = (FP_NBioAPI_CreateTemplate) GetProcAddress(m_hLib, "NBioAPI_CreateTemplate");
	fp_NBioAPI_VerifyMatch = (FP_NBioAPI_VerifyMatch) GetProcAddress(m_hLib, "NBioAPI_VerifyMatch");
	fp_NBioAPI_Enroll = (FP_NBioAPI_Enroll) GetProcAddress(m_hLib, "NBioAPI_Enroll");
	fp_NBioAPI_Verify = (FP_NBioAPI_Verify) GetProcAddress(m_hLib, "NBioAPI_Verify");

	// Skin Function
	fp_NBioAPI_SetSkinResource = (FP_NBioAPI_SetSkinResource) GetProcAddress(m_hLib, "NBioAPI_SetSkinResource");

	m_hBSP = 0;
	m_nFIRFormat = NBioAPI_FIR_FORMAT_EXTENSION;

	NBioAPI_HANDLE handle = 0;
	fp_NBioAPI_Init(&handle);
	debug_message("fp_NBioAPI_Init(&handle);\n");
	m_hBSP = handle;
	return handle;
}

// chequea que la DLL original no ha sido "tocada"
NBioAPI_RETURN FotoNBioAPI_CheckValidity()
{
	return NBioAPI_CheckValidity("NBioBSP.DLL");
}

//devuelve una cadena con los dispositivos conectados, p.ej. "FDU01FD02..."
const char* FotoNBioAPI_EnumerateDevice(NBioAPI_HANDLE g_hBSP)
{
	NBioAPI_RETURN ret;
	NBioAPI_UINT32 nDeviceNum = 0;
	NBioAPI_DEVICE_ID* pDeviceList = NULL;
	static char buf[100];

	sprintf(buf,"Received handle %u\n",g_hBSP);
	debug_message(buf);

	//Get device list in the PC.
	ret = fp_NBioAPI_EnumerateDevice(g_hBSP, &nDeviceNum, &pDeviceList);

	if (ret==NBioAPIERROR_NONE)
	{
		sprintf(buf,"%lu devices found\n", nDeviceNum);
		debug_message(buf);
		if (nDeviceNum == 0)
		{
			return "";
		}
		else
		{
			sprintf(buf,"");
			for (UINT32 i=0;i<nDeviceNum;i++)
			{
				if((pDeviceList[i] & 0x00FF)== NBioAPI_DEVICE_NAME_FDP02)
				{
					sprintf(buf+strlen(buf),"FDP02");
				}
				else if ((pDeviceList[i] & 0x00FF) == NBioAPI_DEVICE_NAME_FDU01)
				{	
					sprintf(buf+strlen(buf),"FDU01");
				}
				
				//else if ((pDeviceList[i] & 0x00FF) == NBioAPI_DEVICE_NAME_OSU01)
				//{	
				//	sprintf(buf+strlen(buf),"OSU01");
				//}
				
				else if ((pDeviceList[i] & 0x00FF) == NBioAPI_DEVICE_NAME_FDU11)
				{	
					sprintf(buf+strlen(buf),"FDU11");
				}
				else if ((pDeviceList[i] & 0x00FF) == NBioAPI_DEVICE_NAME_FSC01)
				{	
					sprintf(buf+strlen(buf),"FSC01");
				}
				
			}
			// para enviarlo en crudo seria tal que asi
			//sprintf(buf, "%d,%d", nDeviceNum, pDeviceList);
			return buf;
		}

		return buf;
	}
	else
	{
		sprintf(buf,"ERROR: 0x%lx\n",ret);
		debug_message(buf);
		return buf;
	}
}

// igual que la función original
NBioAPI_RETURN FotoNBioAPI_OpenDevice (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID)
{
	return fp_NBioAPI_OpenDevice(hHandle,nDeviceID); 
}

// igual que la función original
NBioAPI_RETURN FotoNBioAPI_CloseDevice    (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID)
{
	return fp_NBioAPI_CloseDevice(hHandle,nDeviceID); 
}

// igual que la función original, pero devuelve un puntero al struct del tipo NBioAPI_DEVICE_INFO_0 almacenado en memoria
NBioAPI_DEVICE_INFO_0* FotoNBioAPI_GetDeviceInfo (NBioAPI_HANDLE hHandle, NBioAPI_DEVICE_ID nDeviceID)
{
	memset(&Device_info0, 0, sizeof(Device_info0));
	NBioAPI_RETURN ret = fp_NBioAPI_GetDeviceInfo (hHandle, nDeviceID, 0, &Device_info0);
	return &Device_info0;
}