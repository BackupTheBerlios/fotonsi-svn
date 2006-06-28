#include <windows.h>
#include <stdio.h>
#include <iostream.h>

//extern "C" __declspec(dllimport) int suma(int a, int b);


//explicit runtime linking
// DLL function signature
typedef int (*importFunction)(int, int);

int
main()
{
    importFunction addNumbers;
    int result;

    // Load DLL file
    HINSTANCE hinstLib = LoadLibrary("testdll.dll");
    if (hinstLib == NULL) {
            printf("ERROR: unable to load DLL\n");
            return 1;
    }

    // Get function pointer
    addNumbers = (importFunction)GetProcAddress(hinstLib, "suma");
    if (addNumbers == NULL) {
            printf("ERROR: unable to find DLL function\n");
            return 1;
    }

	int a, b;
	char c;

	cout << "Programa de testeo de la dll\n";
	cout << "Calculo de una suma\n\n";
	cout << "A:";
	cin >> a;
	cout << "B:";
	cin >> b;

	cout << "Suma A+B = " << addNumbers(a,b) << "\n\n";
	cout << "Presione ENTER para finalizar...\n" << endl;

	getchar();

    // Unload DLL file
    FreeLibrary(hinstLib);

    return 0;
}