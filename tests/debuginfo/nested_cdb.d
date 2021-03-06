// REQUIRES: atleast_llvm500
// REQUIRES: Windows
// REQUIRES: cdb
// RUN: %ldc -g -of=%t.exe %s
// RUN: sed -e "/^\\/\\/ CDB:/!d" -e "s,// CDB:,," %s \
// RUN:    | %cdb -snul -lines -y . %t.exe >%t.out
// RUN: FileCheck %s -check-prefix=CHECK -check-prefix=%arch < %t.out

// CDB: ld /f nested_cdb*
// enable case sensitive symbol lookup
// CDB: .symopt-1

void encloser(int arg0, ref int arg1)
{
    int enc_n = 123;
// CDB: bp `nested_cdb.d:16`
// CDB: g
// CDB: dv /t
// CHECK: int arg0 = 0n1
// (cdb displays references as pointers)
// CHECK-NEXT: int * arg1 = {{0x[0-9a-f`]*}}
// CHECK-NEXT: int enc_n = 0n123
// CDB: ?? *arg1
// CHECK: int 0n2
    enc_n += arg1;

    void nested(int nes_i)
    {
        int blub = arg0 + arg1 + enc_n;
// CDB: bp `nested_cdb.d:30`
// CDB: g
// CDB: dv /t
// CHECK: int arg0 = 0n1
// CHECK-NEXT: int * arg1 = {{0x[0-9a-f`]*}}
// CHECK-NEXT: int enc_n = 0n125
// CDB: ?? *arg1
// CHECK: int 0n2
        arg0 = arg1 = enc_n = nes_i;
// CDB: bp `nested_cdb.d:39`
// CDB: g
// CDB: dv /t
// CHECK: int arg0 = 0n456
// CHECK-NEXT: int * arg1 = {{0x[0-9a-f`]*}}
// CHECK-NEXT: int enc_n = 0n456
// CDB: ?? *arg1
// CHECK: int 0n456
    }

    nested(456);
// CDB: bp `nested_cdb.d:50`
// CDB: g
// CDB: dv /t
// the following values are garbage on Win32...
// x64: int arg0 = 0n456
// x64-NEXT: int * arg1 = {{0x[0-9a-f`]*}}
// x64-NEXT: int enc_n = 0n456
// CDB: ?? *arg1
// x64: int 0n456
}

void main()
{
    int arg1 = 2;
    encloser(1, arg1);
}

// CDB: q
// CHECK: quit
