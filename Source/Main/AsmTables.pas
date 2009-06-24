unit AsmTables;

interface

type TRegister = (al,cl,dl,bl,ah,ch,dh,bh,ax,cx,dx,bx,sp,bp,si,di,
                  eax,ecx,edx,ebx,esp,ebp,esi,edi);

// 0 = w field is 0
// 1 = w field is 1
// 2 = filed does not exists
const Registers : Array [TRegister,0..2] of String =
       {al            cl            dl            bl}
      (('','000',''),('','001',''),('','010',''),('','011',''),
       {ah            ch            dh            bh}
       ('','100',''),('','101',''),('','110',''),('','111',''),
       {ax               cx               dx               bx}
       ('000','','100'),('001','','101'),('010','','110'),('011','','111'),
       {sp               bp               si               di}
       ('100','','100'),('101','','101'),('110','','110'),('111','','111'),
       {eax               ecx               edx               ebx}
       ('000','','000'),('001','','001'),('010','','010'),('011','','011'),
       {esp               ebp               esi               edi}
       ('100','','100'),('101','','101'),('110','','110'),('111','','111')
       );

Type TSegmentRegister = (es,cs,ss,ds,fs,gs);

const SRegs2 : Array [TSegmentRegister] of String =
      ('00','01','10','11','','');

const SRegs3 : Array [TSegmentRegister] of String =
      ('000','001','010','011','100','101');

Type TControlRegister = (cr0,cr2,cr3,cr4);
Type TDebugRegister = (dr0,dr1,dr2,dr3,dr6,dr7);

const eee_cr : Array [TControlRegister] of String =
      ('000','001','010','011');
         
const eee_dr : Array [TDebugRegister] of String =
      ('000','010','011','100','110','111');

Type TTestField = (o,no,b,nb,e,ne,be,nbe,s,ns,p,np,l,nl,le,nle);

const tttn : Array [TTestField] of String =
      ('0000','0001','0010','0011',
       '0100','0101','0110','0111',
       '1000','1001','1010','1011',
       '1100','1101','1110','1111');

const InstrIndex : Array ['A'..'Z'] of Integer =
      ({A}  0,{B}-1 ,{C}-1 ,{D}-1 ,{E}-1 ,{F}-1 ,{G}-1 ,{H}-1 ,
       {I}-1 ,{J}-1 ,{K}-1 ,{L}-1 ,{M}-1 ,{N}-1 ,{O}-1 ,{P}-1 ,
       {Q}-1 ,{R}-1 ,{S}-1 ,{T}-1 ,{U}-1 ,{V}-1 ,{W}-1 ,{X}-1 ,
       {Y}-1 ,{Z}-1 );

const INSTR_COUNT =41 ;

const Instructions : Array [0..INSTR_COUNT-1] of String =
{000}      ('AAA 00110111',
{001}       'AAD 11010101:00001010',
{002}       'AAM 11010100:00001010',
{003}       'AAS 00111111',
{004}       'ADC (reg1 reg2) 0001000w:11 reg1 reg2',
{005}       'ADC (reg2 reg1) 0001001w:11 reg1 reg2',
{006}       'ADC (mem reg) 0001001w:mod reg r/m',
{007}       'ADC (reg mem) 0001000w:mod reg r/m',
{008}       'ADC (imdata reg) 100000sw:10010 reg:imdata',
{009}       'ADC (imdata AL,AX,EAX) 0001010w:imdata',
{010}       'ADC (imdata mem) 100000sw:mod 010 r/m:imdata',
{011}       'ADD (reg1 reg2) 0000000w:11 reg1 reg2',
{012}       'ADD (reg2 reg1) 0000001w:11 reg1 reg2',
{013}       'ADD (mem reg) 0000001w:mod reg r/m',
{014}       'ADD (reg mem) 0000000w:mod reg r/m',
{015}       'ADD (imdata reg) 100000sw:11000 reg:imdata',
{016}       'ADD (imdata AL,AX,EAX) 0000010w:imdata',
{017}       'ADD (imdata mem) 100000sw:mod 000 r/m:imdata',
{018}       '',
{019}       '',
{020}       '',
{021}       '',
{022}       '',
{023}       '',
{024}       '',
{025}       '',
{026}       '',
{027}       '',
{028}       '',
{029}       '',
{030}       '',
{031}       '',
{032}       '',
{033}       '',
{034}       '',
{035}       '',
{036}       '',
{037}       '',
{038}       '',
{039}       '',
{040}       ''
            );

implementation

end.
