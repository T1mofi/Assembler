#include <iostream>
#include <math.h>

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

#include <string>

const int ARR_DEMENTION = 10;
const int ONE = 1;

using namespace std;

int main(int argc, char *argv[]) {

	long double arr[ARR_DEMENTION];
	long double sum = 0;
	
	int DE = 0,
		OE = 0,
		UE = 0;

	string stringNumber;

	for (int i = 0; i < 10; i++) {
			cout << "arr[" << i + 1 << "]: ";
			cin >> stringNumber;
			arr[i] = atof(stringNumber.c_str());
			printf("x = %.16e\n", arr[i]);
	}

	for (int i = 0; i < 10; i++) {
		sum += arr[i];
	}
	printf("C   result = %.16e\n", sum);
	sum = 0;

	_asm{
		pusha
		finit								

		fild ARR_DEMENTION					// ST(0) = 10

		fldz								// ST(0) = 0 (iteration)
											// ST(1) = 10                                            ! - 0
		xor EDI, EDI
		loop_start:
			fcom							// compare ST(0) and ST(1)							//  iteration < arrDemention
			fstsw ax						// copy status word(SW) to AX
			and ah, 00000001b				// check C0
				jz to_exit

			fld sum							// ST(0) = sum
											// ST(1) = iteration
											// ST(2) = 10

			fadd arr[EDI]					// ST(0) = sum + arr[EDI]
											// ST(1) = iteration
											// ST(2) = 10

			fstsw ax
			and al, 00001000b
				jnz owerflow

			fstsw ax
			and al, 00010000b
				jnz unowerflow

			fstsw ax
			and al, 00000010b
				jnz denormalized_result

			fstp sum						// sum = ST(0)
											// ST(0) = iteration
											// St(1) = 10

			fiadd ONE						// ST(0) = iteration + 1
											// ST(1) = 10
				
			add EDI, 08h

			jmp loop_start
		loop_end:
		
		owerflow:
			fld1
			fistp OE
			jmp to_exit

		unowerflow:
			fld1
			fistp UE
			jmp to_exit

		denormalized_result:
			fld1
			fistp DE
			jmp to_exit

		to_exit:
			fwait
			popa
	}

	if (!OE && !UE && !DE) {
		printf("ASM   result = %.16e\n", sum);
	}
	else if (OE) {
		cout << "Overflow" << endl;
	}
	else if (UE) {
		cout << "Unowerflow" << endl;
	}
	else if (DE) {
		cout << "Denormalized result" << endl;
	}


	system("pause");
}