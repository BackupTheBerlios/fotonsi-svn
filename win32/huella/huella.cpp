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
//#include "NBioAPI_Type.h"
//#include "FotoNBioAPI.h"
#include "NBioAPI_CheckValidity.h"
#include <iostream.h>
#include <stdlib.h>


extern "C" __declspec(dllexport)void FotoNBioAPI_Init();
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_CheckFinger();
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_FreeFIRHandle(NBioAPI_FIR_HANDLE hFIR);
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_FreeTextFIR(NBioAPI_FIR_TEXTENCODE_PTR pTextFIR);
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_Terminate();
extern "C" __declspec(dllexport)int FotoNBioAPI_InitLog();
extern "C" __declspec(dllexport)int FotoNBioAPI_ShutdownLog();
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_CheckValidity();
extern "C" __declspec(dllexport) const char* FotoNBioAPI_EnumerateDevice();
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_OpenDevice (NBioAPI_DEVICE_ID nDeviceID);
extern "C" __declspec(dllexport)NBioAPI_RETURN FotoNBioAPI_CloseDevice    (NBioAPI_DEVICE_ID nDeviceID);
extern "C" __declspec(dllexport)NBioAPI_DEVICE_INFO_0* FotoNBioAPI_GetDeviceInfo  (NBioAPI_DEVICE_ID nDeviceID);
extern "C" __declspec(dllexport)const char* FotoNBioAPI_Enroll(const char* CaptionMsg, const char* CancelMsg, NBioAPI_UINT8 right_thumb, NBioAPI_UINT8 right_index, NBioAPI_UINT8 right_middle, NBioAPI_UINT8 right_ring, NBioAPI_UINT8 right_little, NBioAPI_UINT8 left_thumb, NBioAPI_UINT8 left_index, NBioAPI_UINT8 left_middle, NBioAPI_UINT8 left_ring, NBioAPI_UINT8 left_little);
extern "C" __declspec(dllexport)const char* FotoNBioAPI_Capture();
extern "C" __declspec(dllexport)BOOL FotoNBioAPI_Verify(const char* plantilla);
extern "C" __declspec(dllexport)BOOL FotoNBioAPI_VerifyMatch(const char* plantilla, const char* huella);

// variables globales que vamos a usar
static NBioAPI_HANDLE m_hBSP;
static NBioAPI_FIR_FORMAT m_nFIRFormat;
static DWORD m_dErrorNum;
static NBioAPI_DEVICE_INFO_0 Device_info0;
static FILE *stream;
static char cadena [100000000];

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

static FP_NBioAPI_CheckFinger			fp_NBioAPI_CheckFinger;

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

NBioAPI_RETURN FotoNBioAPI_Terminate()
{
	debug_message("fp_NBioAPI_Terminate(&m_hBSP);\n");
	return fp_NBioAPI_Terminate(m_hBSP);
}

// inicializa esta DLL y la original, cargando las funciones en memoria
void FotoNBioAPI_Init()
{
	//FotoNBioAPI_InitLog();
	debug_message("FotoNBioAPI_Init called\n");
	//FotoNBioAPI_ShutdownLog();

	HINSTANCE m_hLib;

	m_hLib = 0;
	m_hLib = LoadLibrary("NBioBSP.DLL");
   
    m_dErrorNum = 0;

    if ( !m_hLib )
    {
		debug_message("LoadLibrary failed !!!\n");
		return;
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

	fp_NBioAPI_CheckFinger = (FP_NBioAPI_CheckFinger) GetProcAddress(m_hLib, "NBioAPI_CheckFinger");

	m_hBSP = 0;
	m_nFIRFormat = NBioAPI_FIR_FORMAT_EXTENSION;

	NBioAPI_HANDLE handle = 0;
	fp_NBioAPI_Init(&handle);
	debug_message("fp_NBioAPI_Init(&handle);\n");
	m_hBSP = handle;
	return;
}

// chequea que la DLL original no ha sido "tocada"
NBioAPI_RETURN FotoNBioAPI_CheckValidity()
{
	return NBioAPI_CheckValidity("NBioBSP.DLL");
}

//devuelve una cadena con los dispositivos conectados, p.ej. "FDU01FD02..."
const char* FotoNBioAPI_EnumerateDevice()
{
	NBioAPI_RETURN ret;
	NBioAPI_UINT32 nDeviceNum = 0;
	NBioAPI_DEVICE_ID* pDeviceList = NULL;
	static char buf[100];

	sprintf(buf,"Using handle %u\n",m_hBSP);
	debug_message(buf);

	//Get device list in the PC.
	ret = fp_NBioAPI_EnumerateDevice(m_hBSP, &nDeviceNum, &pDeviceList);

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
NBioAPI_RETURN FotoNBioAPI_OpenDevice (NBioAPI_DEVICE_ID nDeviceID)
{
	return fp_NBioAPI_OpenDevice(m_hBSP,nDeviceID); 
}

// igual que la función original
NBioAPI_RETURN FotoNBioAPI_CloseDevice    (NBioAPI_DEVICE_ID nDeviceID)
{
	return fp_NBioAPI_CloseDevice(m_hBSP,nDeviceID); 
}

// igual que la función original, pero devuelve un puntero al struct del tipo NBioAPI_DEVICE_INFO_0 almacenado en memoria
NBioAPI_DEVICE_INFO_0* FotoNBioAPI_GetDeviceInfo (NBioAPI_DEVICE_ID nDeviceID)
{
	memset(&Device_info0, 0, sizeof(Device_info0));
	NBioAPI_RETURN ret = fp_NBioAPI_GetDeviceInfo (m_hBSP, nDeviceID, 0, &Device_info0);
	return &Device_info0;
}

NBioAPI_RETURN FotoNBioAPI_CheckFinger()
{
	BOOL res;
	return fp_NBioAPI_CheckFinger(m_hBSP,&res);
	//return res;
}

NBioAPI_RETURN FotoNBioAPI_FreeFIRHandle(NBioAPI_FIR_HANDLE hFIR)
{
	return fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
}

NBioAPI_RETURN FotoNBioAPI_FreeTextFIR(NBioAPI_FIR_TEXTENCODE_PTR pTextFIR)
{
	return fp_NBioAPI_FreeTextFIR(m_hBSP,pTextFIR);
}

const char* FotoNBioAPI_Enroll(const char* CaptionMsg, const char* CancelMsg, NBioAPI_UINT8 right_thumb, NBioAPI_UINT8 right_index, NBioAPI_UINT8 right_middle, NBioAPI_UINT8 right_ring, NBioAPI_UINT8 right_little, NBioAPI_UINT8 left_thumb, NBioAPI_UINT8 left_index, NBioAPI_UINT8 left_middle, NBioAPI_UINT8 left_ring, NBioAPI_UINT8 left_little)
{
	NBioAPI_FIR_HANDLE hFIR = NULL;
	NBioAPI_FIR_PAYLOAD* payload = NULL;
	NBioAPI_RETURN err;
	NBioAPI_INPUT_FIR_PTR pstored_template = NULL;
	NBioAPI_SINT32 time_out = -1; // 10000;
	NBioAPI_FIR_HANDLE_PTR paudit_data = NULL;

	NBioAPI_WINDOW_OPTION   m_WinOption;
	NBioAPI_WINDOW_OPTION_2 m_WinOption2;
	TCHAR                   m_szCaptionMsg[256];
	TCHAR                   m_szCancelMsg[256];

    memset(&m_WinOption, 0, sizeof(NBioAPI_WINDOW_OPTION));
	m_WinOption.Length = sizeof(NBioAPI_WINDOW_OPTION);

	m_WinOption.CaptionMsg = LPTSTR (CaptionMsg);
	m_WinOption.CancelMsg = LPTSTR (CancelMsg);
	m_WinOption.FingerWnd = NULL;
	m_WinOption.WindowStyle = NBioAPI_WINDOW_STYLE_POPUP;
	//m_WinOption.WindowStyle = NBioAPI_WINDOW_STYLE_INVISIBLE;
	//m_WinOption.WindowStyle = NBioAPI_WINDOW_STYLE_CONTINUOUS;

	//m_WinOption.WindowStyle |= NBioAPI_WINDOW_STYLE_NO_FPIMG;
	//m_WinOption.WindowStyle |= NBioAPI_WINDOW_STYLE_NO_TOPMOST;
	m_WinOption.WindowStyle |= NBioAPI_WINDOW_STYLE_NO_WELCOME;

	memset(&m_WinOption2, 0, sizeof(m_WinOption2));
	//memcpy(m_WinOption2.DisableFingerForEnroll,DisableFingerForEnroll,10*sizeof(NBioAPI_UINT8));
	m_WinOption2.DisableFingerForEnroll[0] = right_thumb;
	m_WinOption2.DisableFingerForEnroll[1] = right_index;
	m_WinOption2.DisableFingerForEnroll[2] = right_middle;
	m_WinOption2.DisableFingerForEnroll[3] = right_ring;
	m_WinOption2.DisableFingerForEnroll[4] = right_little;
	m_WinOption2.DisableFingerForEnroll[5] = left_thumb;
	m_WinOption2.DisableFingerForEnroll[6] = left_index;
	m_WinOption2.DisableFingerForEnroll[7] = left_middle;
	m_WinOption2.DisableFingerForEnroll[8] = left_ring;
	m_WinOption2.DisableFingerForEnroll[9] = left_little;
	//memcpy(m_WinOption2.FPForeColor,FPForeColor,3*sizeof(NBioAPI_UINT8));
	//memcpy(m_WinOption2.FPBackColor,FPBackColor,3*sizeof(NBioAPI_UINT8));
	m_WinOption.Option2 = &m_WinOption2;

	err = fp_NBioAPI_Enroll(m_hBSP, NULL, &hFIR, payload, time_out, NULL, &m_WinOption);
	//err = fp_NBioAPI_Enroll(m_hBSP, NULL, &hFIR, payload, time_out, NULL, NULL);

/*
	if (err==NBioAPIERROR_NONE)
	{
		NBioAPI_FIR_TEXTENCODE hTextFIR;
		memset(&hTextFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
		fp_NBioAPI_GetTextFIRFromHandle(m_hBSP, hFIR, &hTextFIR, FALSE); //extended??
		strcpy(cadena,hTextFIR.TextFIR);
		fp_NBioAPI_FreeTextFIR(m_hBSP, &hTextFIR);
		return (const char*) cadena;
	}
*/
	switch (err) {
		case NBioAPIERROR_NONE:
			NBioAPI_FIR_TEXTENCODE hTextFIR;
			memset(&hTextFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
			fp_NBioAPI_GetTextFIRFromHandle(m_hBSP, hFIR, &hTextFIR, FALSE); //extended??
			strcpy(cadena,hTextFIR.TextFIR);
			fp_NBioAPI_FreeTextFIR(m_hBSP, &hTextFIR);
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return (const char*) cadena;
		case NBioAPIERROR_INVALID_HANDLE:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_INVALID_HANDLE";
		case NBioAPIERROR_INVALID_POINTER:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_INVALID_POINTER";
		case NBioAPIERROR_DEVICE_NOT_OPENED:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_DEVICE_NOT_OPENED";
		case NBioAPIERROR_ENCRYPTED_DATA_ERROR:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_ENCRYPTED_DATA_ERROR";
		case NBioAPIERROR_INTERNAL_CHECKSUM_FAIL:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_INTERNAL_CHECKSUM_FAIL";
		case NBioAPIERROR_FUNCTION_FAIL:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_FUNCTION_FAIL";
		case NBioAPIERROR_USER_CANCEL:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "NBioAPIERROR_USER_CANCEL";
		default:
			fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
			return "Unknown Error";
		}
}

BOOL FotoNBioAPI_Verify(const char* plantilla)
{
	NBioAPI_BOOL res = FALSE;
	NBioAPI_FIR_PAYLOAD pl;
	NBioAPI_SINT32 time_out = -1; // 10000;
	NBioAPI_FIR_HANDLE_PTR paudit_data = NULL;
	NBioAPI_WINDOW_OPTION_PTR pwindow = NULL;

	NBioAPI_INPUT_FIR input_fir;
	NBioAPI_FIR_TEXTENCODE textFIR;
	textFIR.IsWideChar = FALSE;
	memset(&textFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
	textFIR.TextFIR = strdup(plantilla);

	//NBioAPI_FIR_HANDLE hFIR;
    input_fir.Form = NBioAPI_FIR_FORM_TEXTENCODE;
	input_fir.InputFIR.TextFIR = (NBioAPI_FIR_TEXTENCODE_PTR) &textFIR;

	fp_NBioAPI_Verify(m_hBSP,&input_fir,&res,&pl,time_out,paudit_data,pwindow);
	free(textFIR.TextFIR);
	return res;
}

const char* FotoNBioAPI_Capture()
{
	NBioAPI_FIR_HANDLE hFIR = NULL;
	NBioAPI_FIR_PAYLOAD* payload = NULL;
	NBioAPI_RETURN err;
	NBioAPI_INPUT_FIR_PTR pstored_template = NULL;
	NBioAPI_SINT32 time_out = -1; // 10000;
	NBioAPI_FIR_HANDLE_PTR paudit_data = NULL;
	NBioAPI_WINDOW_OPTION_PTR pwindow = NULL;
   
	err = fp_NBioAPI_Capture(m_hBSP, NBioAPI_FIR_PURPOSE_IDENTIFY, &hFIR, time_out, NULL, NULL);

	if (err==NBioAPIERROR_NONE)
	{
		NBioAPI_FIR_TEXTENCODE hTextFIR;
		memset(&hTextFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
		fp_NBioAPI_GetTextFIRFromHandle(m_hBSP, hFIR, &hTextFIR, FALSE); //extended??
		strcpy(cadena,hTextFIR.TextFIR);
		fp_NBioAPI_FreeTextFIR(m_hBSP, &hTextFIR);
		return (const char*) cadena;
	}
	else return "ERROR";

	fp_NBioAPI_FreeFIRHandle(m_hBSP,hFIR);
}

BOOL FotoNBioAPI_VerifyMatch(const char* plantilla, const char* huella)
{
	NBioAPI_BOOL res = FALSE;
	NBioAPI_FIR_PAYLOAD pl;
	NBioAPI_SINT32 time_out = -1; // 10000;
	NBioAPI_FIR_HANDLE_PTR paudit_data = NULL;
	NBioAPI_WINDOW_OPTION_PTR pwindow = NULL;

	NBioAPI_INPUT_FIR input_fir;
	NBioAPI_FIR_TEXTENCODE textFIR;
	textFIR.IsWideChar = FALSE;
	memset(&textFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
	textFIR.TextFIR = strdup(huella);

	//NBioAPI_FIR_HANDLE hFIR;
    input_fir.Form = NBioAPI_FIR_FORM_TEXTENCODE;
	input_fir.InputFIR.TextFIR = (NBioAPI_FIR_TEXTENCODE_PTR) &textFIR;

	NBioAPI_INPUT_FIR stored_fir;
	NBioAPI_FIR_TEXTENCODE s_textFIR;
	s_textFIR.IsWideChar = FALSE;
	memset(&s_textFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
	s_textFIR.TextFIR = strdup(plantilla);

	//NBioAPI_FIR_HANDLE hFIR;
    stored_fir.Form = NBioAPI_FIR_FORM_TEXTENCODE;
	stored_fir.InputFIR.TextFIR = (NBioAPI_FIR_TEXTENCODE_PTR) &s_textFIR;

	fp_NBioAPI_VerifyMatch(m_hBSP,&input_fir,&stored_fir,&res,&pl);
	free(textFIR.TextFIR);
	return res;
}