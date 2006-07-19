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
#include "NBioAPI_CheckValidity.h"

extern "C" __declspec(dllexport) NBioAPI_RETURN FotoNBioAPI_CheckValidity(LPCTSTR szModulePath);
extern "C" __declspec(dllexport) const char* FotoNBioAPI_EnumerateDevice();

NBioAPI_RETURN FotoNBioAPI_CheckValidity(LPCTSTR szModulePath)
{
	return NBioAPI_CheckValidity(szModulePath);
}

const char* FotoNBioAPI_EnumerateDevice(NBioAPI_HANDLE g_hBSP)
{
	NBioAPI_RETURN ret;
	NBioAPI_UINT32 nDeviceNum;
	NBioAPI_DEVICE_ID **pDeviceList;
	char buf[100];

	//Get device list in the PC.
	ret = NBioAPI_EnumerateDevice(g_hBSP, &nDeviceNum, pDeviceList);
	/*for (UINT32 i=0;i<nDeviceNum;i++)
	{
		if((pDeviceList(i) & 0x00FF)== NBioAPI_DEVICE_NAME_FDP02)
		{
			sprintf(buf,"FDP02");
		}
		else if ((pDeviceList(i) & 0x00FF)) == NBioAPI_DEVICE_NAME_FDU01)
		{	
			sprintf(buf,"FDU01");
		}
	}*/
	sprintf(buf,"%d", nDeviceNum);
	return buf;

	//char buf[100];
	//snprintf(buf, sizeof(buf), "%d,%d", nDeviceNum, pDeviceList);
	//return buf;
}
