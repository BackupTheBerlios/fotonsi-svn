#include <windows.h>
#include <stdio.h>
#include <iostream.h>

//extern "C" __declspec(dllimport) int suma(int a, int b);

/* test_struct */
typedef struct test_struct {
	UINT32      f;  /* must be 0 */
	UINT32      e;     /* Read Only */
	UINT32      d;    /* Read Only */
	UINT32      c;
	UINT32      b;
	UINT32      a;
} TEST_STRUCT;

//explicit runtime linking
// DLL function signature
typedef int (*importFunction)(int, int);
typedef TEST_STRUCT (*fp_test)(UINT32 a, UINT32 b, UINT32 c, UINT32 d, UINT32 e, UINT32 f);

int
main()
{
    importFunction addNumbers;
	fp_test test;
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

    // Get function pointer
    test = (fp_test)GetProcAddress(hinstLib, "test");
    if (test == NULL) {
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

	TEST_STRUCT st = test(1,2,3,4,5,6);

	cout << "Presione ENTER para finalizar...\n" << endl;

	getchar();

    // Unload DLL file
    FreeLibrary(hinstLib);

    return 0;
}