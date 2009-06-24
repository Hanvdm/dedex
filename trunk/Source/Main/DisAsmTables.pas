unit DisAsmTables;

interface

{ Code First character after #:
      A: Direct Address.
      C: Reg field in ModRm specifies Control register.
      D: Reg field in ModRm specifies Debug register.
      E: General purpose register or memory address specified in the ModRM byte.
      F: EFlags register
      G: Reg field in ModRM specifies a general register
      H: Signed immidiate data
      I: Imidiate data
      J: Relative jump Offset
      M: memory address spcified in the ModRM byte.
      O: Relative Offset Word or DWord
      P: Reg field in ModRM specifies a MMX register
      Q: MMX register or memory address specified in the ModRM byte.
      R: general purpose register specified in the ModRM byte.
      S: Reg field in ModRM specifies a Segment register
      T: Reg field in ModRM specifies a MMX register
      P: Seg prefix override.

  Second character after #
      a: two Word or two DWord, only used by BOUND
      b: Byte.
      c: Byte or word
      d: DWord
      p: 32 or 16 bit pointer
      q: QWord
      s: 6Byte
      v: Word or DWord
      w: Word
      t: Tera byte

  Third character after #
      j: jump Operand (Relative or absolute)

  First character after @
      e: used by register (@eax, @esp ..) return e with the character following when
         operand size = 4 ortherwise only the following character.
      g: Group, return the group insruction specified by OperandType
         and the reg field of the ModRM byte.
      h: Operand for group, return operands for the group insruction specified
         by OperandType and the reg field of the ModRM byte.
      m: Must have size, Size indicator always set.
      o: Operand size, returns the name (bwdq) of the number following, divided
         by two when operand size <> 4.
      p: Seg prefix override. Sets the prefix to the following charchter + 's'
      s: Size override (address or operand).
         follow by o: operand size override
                   a: address size override

  First character after %
      c: Use the opcode instead in addition to the assembler instruction
}
      
const
  OneByteOpcodes: array[char] of string =
   // 0
   ('add     #Eb , #Gb ',  'add     #Ev , #Gv ',      'add     #Gb , #Eb ',  'add     #Gv , #Ev ',
    'add     al, #Hb ',   'add     @eax, #Hv ',     'push    es',        'pop     es',
    'or      #Eb , #Gb ',  'or      #Ev , #Gv ',      'or      #Gb , #Eb ',  'or      #Gv , #Ev ',
    'or      al, #Ib ',   'or      @eax, #Iv ',     'push    cs',        '@c2',
   // 1
    'adc     #Eb , #Gb ',  'adc     #Ev , #Gv ',      'adc     #Gb , #Eb ',  'adc     #Gv , #Ev ',
    'adc     al, #Ib ',   'adc     @eax, #Iv ',     'push    ss',        'pop     ss',
    'sbb     #Eb , #Gb ',  'sbb     #Ev , #Gv ',      'sbb     #Gb , #Eb ',  'sbb     #Gv , #Ev ',
    'sbb     al, #Ib ',   'sbb     @eax, #Iv ',     'push    ds',        'pop     ds',
   // 2
    'and     #Eb , #Gb ',  'and     #Ev , #Gv ',      'and     #Gb , #Eb ',  'and     #Gv , #Ev ',
    'and     al, #Ib ',   'and     @eax, #Iv ',     '@pe',               'daa',
    'sub     #Eb , #Gb ',  'sub     #Ev , #Gv @m ',      'sub     #Gb , #Eb ',  'sub     #Gv , #Ev @m ',
    'sub     al, #Ib ',   'sub     @eax, #Iv ',     '@pc',               'das',
   // 3
    'xor     #Eb , #Gb ',  'xor     #Ev , #Gv ',      'xor     #Gb , #Eb ',  'xor     #Gv , #Ev ',
    'xor     al, #Ib ',   'xor     @eax, #Iv ',     '@ps',               'aaa',
    'cmp     #Eb , #Gb ',  'cmp     #Ev , #Gv ',      'cmp     #Gb , #Eb ',  'cmp     #Gv , #Ev ',
    'cmp     al, #Ib ',   'cmp     @eax, #Iv ',     '@pd',               'aas',
   // 4
    'inc     @eax',      'inc     @ecx',          'inc     @edx',      'inc     @ebx',
    'inc     @esp',      'inc     @ebp',          'inc     @esi',      'inc     @edi',
    'dec     @eax',      'dec     @ecx',          'dec     @edx',      'dec     @ebx',
    'dec     @esp',      'dec     @ebp',          'dec     @esi',      'dec     @edi',
   // 5
    'push    @eax',      'push    @ecx',          'push    @edx',      'push    @ebx',
    'push    @esp',      'push    @ebp',          'push    @esi',      'push    @edi',
    'pop     @eax',      'pop     @ecx',          'pop     @edx',      'pop     @ebx',
    'pop     @esp',      'pop     @ebp',          'pop     @esi',      'pop     @edi',
   // 6
    'pusha',             'popa',                  'bound   #Gv , #Ma ',  'arpl    #Ew , #Gw ',
    '@pf',               '@pg',                   '@so',               '@sa',
    'push    #Iv ',       'imul    #Gv , #Ev , #Iv ', 'push    #Ib ',       'imul    #Gv , #Ev , #Ib ',
    'insb',   'ins@o4',       'outsb',   'outs@o4',
   // 7
    'jo      #Jbj',       'jno     #Jbj',           'jb      #Jbj',       'jnb     #Jbj',
    'jz      #Jbj',       'jnz     #Jbj',           'jbe     #Jbj',       'jnbe    #Jbj',
    'js      #Jbj',       'jns     #Jbj',           'jp      #Jbj',       'jnp     #Jbj',
    'jl      #Jbj',       'jnl     #Jbj',           'jle     #Jbj',       'jnle    #Jbj',
   // 8
    '@ga#Eb , #Ib ',       '@ga#Ev , #Iv ',           '@ga#Ev , #Ib ',       '@ga#Ev , #Hb ',
    'test    #Eb , #Gb ',  'test    #Ev , #Gv ',      'xchg    #Eb , #Gb ',  'xchg    #Ev , #Gv ',
    'mov     #Eb , #Gb ',  'mov     #Ev , #Gv ',      'mov     #Gb , #Eb ',  'mov     #Gv , #Ev ',
    'mov     #Ew , #Sw ',  'lea     #Gv , #M  ',      'mov     #Sw , #Ew ',  'pop     #Ev ',
   // 9
    'nop',               'xchg    eax, @ecx',     'xchg    eax, @edx', 'xchg    eax, @ebx',
    'xchg    eax, @esp', 'xchg    eax, @ebp',     'xchg    eax, @esi', 'xchg    eax, @edi',
    'c@o2@o4@e ',               'c@o4@o8',                 'call    #Ap ',       'wait',
    'pushf   #Fv ',       'pop     #Fv ',           'sahf',              'lahf',
   // A
    'mov     al, #Ob ',   'mov     @eax, #Ov ',     'mov     #Ob , al',   'mov     #Ov , @eax',
    'movsb',  'movs@o4',      'cmpsb',  'cmps@o4',
    'test    al, #Ib ',   'test    @eax, #Iv ',     'stosb',   'stos@o4',
    'lodsb',   'lods@o4',     'scasb',   'scas@o4',
   // B
    'mov     al, #Ib ',   'mov     cl, #Ib ',       'mov     dl, #Ib ',   'mov     bl, #Ib ',
    'mov     ah, #Ib ',   'mov     ch, #Ib ',       'mov     dh, #Ib ',   'mov     bh, #Ib ',
    'mov     @eax, #Iv ', 'mov     @ecx, #Iv ',     'mov     @edx, #Iv ', 'mov     @ebx, #Iv ',
    'mov     @esp, #Iv ', 'mov     @ebp, #Iv ',     'mov     @esi, #Iv ', 'mov     @edi, #Iv ',
   // C                                               //Fixed by DaFixer from 'ret     #Ib '
    '@gb#Eb , #Ib ',       '@gb#Ev , #Ib ',           'ret     #Iw ',       'ret',
    'les     #Gv , #Mp ',  'lds     #Gv , #Mp ',      'mov     #Eb , #Ib ',  'mov     #Ev , #Iv ',
    'enter   #Lw , #Ib ',  'leave',                 'ret     #Lw ',       'ret',
    'int     3',         'int     #Ib ',           'into',              'iret',
   // D
    '@gb#Eb , 1',         '@gb#Ev , 1',             '@gb#Eb , cl',        '@gb#Ev , cl',
    'aam',               'aad',                   '%c ',                  'xlat',
    '@ca',               '@cb',                   '@cc',               '@cd',
    '@ce',               '@cf',                   '@cg',               '@ch',
   // E
    'loopn   #Jbj',       'loope   #Jbj',           'loop    #Jbj',       'jcxz    #Jbj',
    'in      al, #Ib ',   'in      @eax, #Ib ',     'out     #Ib , al',   'out     #Ib , @eax',
    'call    #Jvc',       'jmp     #Jvj',           'jmp     #Ap ',       'jmp     #Jbj',
    'in      al, dx',    'in      @eax, dx',      'out     dx, al',    'out     dx, @eax',
   // F
    'lock',              '%c ',                      'repne',             'rep',
    'hlt',               'cmc',                   '@gc#Eb @h1',         '@gc#Ev @h2 ',
    'clc',               'stc',                   'cli',               'sti',
    'cld',               'std',                   '@gd@h3',            '@ge@h4');

  // @c2
  TwoByteOpcodes: array[char] of string =
   // 0
   ('@gf',               '%c ',                      'lar     #Gv , #Ew ',  'lsl     #Gv , #Ew ',
    '%c ',                  '%c ',                      'ctls',              '%c ',
    'invd',              'wbinvd',                '%c ',                  'ud2',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
   // 1
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
   // 2
    'mov     #Rd , #Cd ',  'mov     #Rd , #Dd ',      'mov     #Cd , #Rd ',  'mov     #Dd , #Cd ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
   // 3
    'wrmsr',             'rdtsc',                 'rdmsr',             'rdpmc',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
   // 4
    'cmovo   #Gv , #Ev ',  'cmovno  #Gv , #Ev ',      'cmovb   #Gv , #Ev ',  'cmovnb  #Gv , #Ev ',
    'cmove   #Gv , #Ev ',  'cmovne  #Gv , #Ev ',      'cmovbe  #Gv , #Ev ',  'cmovnbe #Gv , #Ev ',
    'cmovs   #Gv , #Ev ',  'cmovns  #Gv , #Ev ',      'cmovp   #Gv , #Ev ',  'cmovnp  #Gv , #Ev ',
    'cmovl   #Gv , #Ev ',  'cmovnl  #Gv , #Ev ',      'cmovle  #Gv , #Ev ',  'cmovnle #Gv , #Ev ',
   // 5
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
   // 6
    'punpcklbw #Pq , #Qd ','punpcklwd #Pq , #Qd ',    'punpckldq #Pq , #Qd ','packusdw #Pq , #Qd ',
    'pcmpgtb #Pq , #Qd ',  'pcmpgtw #Pq , #Qd ',      'pcmpgtd #Pq , #Qd ',  'packsswb #Pq , #Qd ',
    'punpckhbw #Pq , #Qd ','punpckhwd #Pq , #Qd ',    'punpckhdq #Pq , #Qd ','packssdw #Pq , #Qd ',
    '%c ',                  '%c ',                      'movd    #Pd , #Ed ',  'movq    #Pq , #Qq ',
   // 7
    '%c ',                  '@gg',                   '@gh',               '@gi',
    'pcmpeqb #Pq , #Qd ',  'pcmpeqw #Pq , #Qd ',      'pcmpeqd #Pq , #Qd ',  'emms',
    '%c ',                  '%c ',                      '%c ',                  '%c ',
    '%c ',                  '%c ',                      'movd    #Ed , #Pd ',  'movq    #Qq , #Pq ',
   // 8
    'jo      #Jvj',       'jno     #Jvj',           'jb      #Jvj',       'jnb     #Jvj',
    'jz      #Jvj',       'jnz     #Jvj',           'jbe     #Jvj',       'jnbe    #Jvj',
    'js      #Jvj',       'jns     #Jvj',           'jp      #Jvj',       'jnp     #Jvj',
    'jl      #Jvj',       'jnl     #Jvj',           'jle     #Jvj',       'jnle    #Jvj',
   // 9
    'seto    #Eb ',       'setno   #Eb ',           'setb    #Eb ',       'setnb   #Eb ',
    'setz    #Eb ',       'setnz   #Eb ',           'setbe   #Eb ',       'setnbe  #Eb ',
    'sets    #Eb ',       'setns   #Eb ',           'setp    #Eb ',       'setnp   #Eb ',
    'setl    #Eb ',       'setnl   #Eb ',           'setle   #Eb ',       'setnle  #Eb ',
   // A
    'push    fs',        'pop     fs',            'cpuid',             'bt      #Ev , #Gv %m ',
    'shld    #Ev , #Gv , #Ib ', 'shld    #Ev , #Gv , cl', '%c ',               '%c ',
    'push    gs',        'pop     gs',            'rsm',               'bts     #Ev , #Gv ',
    'shrd    #Ev , #Gv , #Ib ', 'shrd    #Ev , #Gv , cl', '%c ',               'imul    #Gv , #Ev ',
   // B
    'cmpxchg #Eb , #Gb ',  'cmpxchg #Ev , #Gv ',      'lss     #Mp ',       'btr     #Ev , #Gv ',
    'lfs     #Mp ',       'lgs     #Mp ',           'movzx   #Gv , @m #Eb ',  'movzx   #Gv , @m #Ew ',
    '%c ',                  'ud2',                   '@gb     #Ev , #Ib ',  'btc     #Ev , #Gv ',
    'bsf     #Gv , #Ev ',  'bsr     #Gv , #Ev ',      'movsx   #Gv ,@m  #Eb ',  'movsx   #Gv ,@m  #Ew ',
   // C
    'xadd   #Eb , #Gb ',   'xadd    #Ev , #Gv ',      '%c ',                  '%c ',
    '%c ',                  '%c ',                      '%c ',                  '@gj',
    'bswap   @eax',      'bswap   @ecx',          'bswap   @edx',      'bswap   @ebx',
    'bswap   @esp',      'bswap   @ebp',          'bswap   @esi',      'bswap   @edi',
   // D
    '%c ',                  'psrlw   #Pq , #Qd ',      'psrld   #Pq , #Qd ',  'prslq   #Pq , #Qd ',
    '%c ',                  'pmullw  #Pq , #Qd ',      '%c ',                  '%c ',
    'pcubusb #Pq , #Qq ',  'pcubusw #Pq , #Qq ',      '%c ',                  'pand    #Pq , #Qq ',
    'paddusb #Pq , #Qq ',  'paddusw #Pq , #Qq ',      '%c ',                  'pandn   #Pq , #Qq ',
   // E
    '%c ',                  'psraw   #Pq , #Qd ',      'psrad   #Pq , #Qd '   ,'%c ',
    '%c ',                  'pmulhw  #Pq , #Qd ',      '%c ',                  '%c ',
    'psubsb  #Pq , #Qq ',  'psubsw  #Pq , #Qq ',      '%c ',                  'por     #Pq , #Qq ',
    'paddsb  #Pq , #Qq ',  'paddsw  #Pq , #Qq ',      '%c ',                  'pxor    #Pq , #Qq ',
   // F
    '%c ',                  'psllw   #Pq , #Qd ',      'pslld   #Pq , #Qd ',  'prllq   #Pq , #Qd ',
    '%c ',                  'pmaddwd #Pq , #Qd ',      '%c ',                  '%c ',
    'psubb   #Pq , #Qq ',  'psubw   #Pq , #Qq ',      'psubd   #Pq , #Qq ',  '%c ',
    'paddb   #Pq , #Qq ',  'paddw   #Pq , #Qq ',      'paddd   #Pq , #Qq ',  '%c ');

  // @g
  GroupsOpcodes: array['a'..'j', 0..7] of string =
    // 'a'
    (('add     ',    'or      ',    'adc     ',    'sbb     ',
      'and     ',    'sub     ',    'xor     ',    'cmp     '),
    // 'b'
     ('rol     ',    'ror     ',    'rcl     ',    'rcr     ',
      'shl     ',    'shr     ',    '%c       ',    'sar     '),
    // 'c'
     ('test    ',    '%c       ',    'not     ',    'neg     ',
      'mul     ',    'imul    ',    'div     ',    'idiv    '),
    // 'd'
     ('inc     ',    'dec     ',    '%c       ',    '%c       ',
      '%c       ',    '%c       ',    '%c       ',    '%c       '),
    // 'e'
     ('inc     ',    'dec     ',    'call    ',    'call    ',
      'jmp     ',    'jmp     ',    'push    ',    '%c       '),
    // 'f'
     ('sldt    #Ew ', 'str     #Ew ', 'lldt    #Ew ', 'ltr     #Ew ',
      'verr    #Ew ', 'verw    #Ew ', '%c       ',    '%c       '),
    // 'g'
     ('%c ',            '%c ',            'psrld   #Pq , #Ib ', '%c ',
      'psrad   #Pq , #Ib ', '%c ',       'pslld   #Pq , #Ib ', '%c '),
    // 'h'
     ('%c ',            '%c ',            'psrlw   #Pq , #Ib ', '%c ',
      'psraw   #Pq , #Ib ', '%c ',       'psllw   #Pq , #Ib ', '%c '),
    // 'i'
     ('%c ',            '%c ',            'psrlq   #Pq , #Ib ', '%c ',
      '%c ',            '%c ',            'psllq   #Pq , #Ib ', '%c '),
    // 'j'
     ('%c ',            'cmpxchg8b #Mq ', '%c ',          '%c ',
      '%c ',            '%c ',            '%c ',            '%c '));

  // @h
  GroupsOperands: array['1'..'4', 0..7] of string =
    // '1'  Group 3 with 8 bit operand
    ((', #Ib ', '',    '',      '',     ', al',   ', al',   '',   ''),
    // '2'  Group 3 with 16/32 bit operand
     (', #Iv ', '',    '',      '',     '', '', '', ''),
    // '3'  Group 4
     ('#Eb ',   '#Eb ', '',      '',     '',       '',       '',       ''),
    // '4'  Group 5
     ('#Ev ',   '#Ev ', '#Ev ',   '#Ep ',  '#Ev ',    '#Ep ',    '#Ev ', ''));

  // @c
  // $b8 .. $bf represent 0..7 for when modrm byte is within $00 to $bf
  FloatingPointOpcodes: array['a'..'h', $b8..$ff] of string =
    // 'a'
    (('fadd    #Ed ',    'fmul    #Ed ',    'fcom    #Ed ',    'fcomp   #Ed ',
      'fsub    #Ed ',    'fsubr   #Ed ',    'fdiv    #Ed ',    'fdivr   #Ed ',
      'fadd    st(0), st(0)',  'fadd    st(0), st(1)',  'fadd    st(0), st(2)',  'fadd    st(0), st(3)',
      'fadd    st(0), st(4)',  'fadd    st(0), st(5)',  'fadd    st(0), st(6)',  'fadd    st(0), st(7)',
      'fmul    st(0), st(0)',  'fmul    st(0), st(1)',  'fmul    st(0), st(2)',  'fmul    st(0), st(3)',
      'fmul    st(0), st(4)',  'fmul    st(0), st(5)',  'fmul    st(0), st(6)',  'fmul    st(0), st(7)',
      'fcom    st(0), st(0)',  'fcom    st(0), st(1)',  'fcom    st(0), st(2)',  'fcom    st(0), st(3)',
      'fcom    st(0), st(4)',  'fcom    st(0), st(5)',  'fcom    st(0), st(6)',  'fcom    st(0), st(7)',
      'fcomp   st(0), st(0)',  'fcomp   st(0), st(1)',  'fcomp   st(0), st(2)',  'fcomp   st(0), st(3)',
      'fcomp   st(0), st(4)',  'fcomp   st(0), st(5)',  'fcomp   st(0), st(6)',  'fcomp   st(0), st(7)',
      'fsub    st(0), st(0)',  'fsub    st(0), st(1)',  'fsub    st(0), st(2)',  'fsub    st(0), st(3)',
      'fsub    st(0), st(4)',  'fsub    st(0), st(5)',  'fsub    st(0), st(6)',  'fsub    st(0), st(7)',
      'fsubr   st(0), st(0)',  'fsubr   st(0), st(1)',  'fsubr   st(0), st(2)',  'fsubr   st(0), st(3)',
      'fsubr   st(0), st(4)',  'fsubr   st(0), st(5)',  'fsubr   st(0), st(6)',  'fsubr   st(0), st(7)',
      'fdiv    st(0), st(0)',  'fdiv    st(0), st(1)',  'fdiv    st(0), st(2)',  'fdiv    st(0), st(3)',
      'fdiv    st(0), st(4)',  'fdiv    st(0), st(5)',  'fdiv    st(0), st(6)',  'fdiv    st(0), st(7)',
      'fdivr   st(0), st(0)',  'fdivr   st(0), st(1)',  'fdivr   st(0), st(2)',  'fdivr   st(0), st(3)',
      'fdivr   st(0), st(4)',  'fdivr   st(0), st(5)',  'fdivr   st(0), st(6)',  'fdivr   st(0), st(7)'),
    // 'b'
     ('fld     #Ed ',    '%c ',               'fst     #Ed ',    'fstp    #Ed ',
      'fldenv  #E  ',    'fldcw   #Ew ',    'fstenv  #E  ',    'fstcw   #Ew ',
      'fld     st(0), st(0)',  'fld     st(0), st(1)',  'fld     st(0), st(2)',  'fld     st(0), st(3)',
      'fld     st(0), st(4)',  'fld     st(0), st(5)',  'fld     st(0), st(6)',  'fld     st(0), st(7)',
      'fxch    st(0), st(0)',  'fxch    st(0), st(1)',  'fxch    st(0), st(2)',  'fxch    st(0), st(3)',
      'fxch    st(0), st(4)',  'fxch    st(0), st(5)',  'fxch    st(0), st(6)',  'fxch    st(0), st(7)',
      'fnop',           '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      'fchs',           'fabs',           '%c ',               '%c ',
      'tst',            'xam',            '%c ',               '%c ',
      'fld1',           'fldl2t',         'fldl2e',         'fldp1',
      'fldlg2',         'fldln2',         'fldz',           '%c ',
      'f2xm1',          'fyl2x',          'fptan',          'fpatan',
      'fxtract',        'fprem1',         'fdecstp',        'fincstp',
      'fprem',          'fyl2xp1',        'fsqrt',          'fsincos',
      'frndint',        'fscale',         'fsing',          'fcos'),
    // 'c'
     ('fiadd   #Ed ',    'fimul   #Ed ',    'ficom   #Ed ',    'ficomp  #Ed ',
      'fisub   #Ed ',    'fisubr  #Ed ',    'fidiv   #Ed ',    'fidivr  #Ed ',
      'fcmovb  st(0), st(0)',  'fcmovb  st(0), st(1)',  'fcmovb  st(0), st(2)',  'fcmovb  st(0), st(3)',
      'fcmovb  st(0), st(4)',  'fcmovb  st(0), st(5)',  'fcmovb  st(0), st(6)',  'fcmovb  st(0), st(7)',
      'fcmove  st(0), st(0)',  'fcmove  st(0), st(1)',  'fcmove  st(0), st(2)',  'fcmove  st(0), st(3)',
      'fcmove  st(0), st(4)',  'fcmove  st(0), st(5)',  'fcmove  st(0), st(6)',  'fcmove  st(0), st(7)',
      'fcmovbe st(0), st(0)',  'fcmovbe st(0), st(1)',  'fcmovbe st(0), st(2)',  'fcmovbe st(0), st(3)',
      'fcmovbe st(0), st(4)',  'fcmovbe st(0), st(5)',  'fcmovbe st(0), st(6)',  'fcmovbe st(0), st(7)',
      'fcmovu  st(0), st(0)',  'fcmovu  st(0), st(1)',  'fcmovu  st(0), st(2)',  'fcmovu  st(0), st(3)',
      'fcmovu  st(0), st(4)',  'fcmovu  st(0), st(5)',  'fcmovu  st(0), st(6)',  'fcmovu  st(0), st(7)',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               'fucompp',        '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c '),
    // 'd'
     ('fild    #Ed ',    '%c ',               'fist    #Ed ',    'fistp   #Ed ',
      '%c ',               'fld     #Et ',    '%c ',               'fstp    #Et ',
      'fcmovnb st(0), st(0)',  'fcmovnb st(0), st(1)',  'fcmovnb st(0), st(2)',  'fcmovnb st(0), st(3)',
      'fcmovnb st(0), st(4)',  'fcmovnb st(0), st(5)',  'fcmovnb st(0), st(6)',  'fcmovnb st(0), st(7)',
      'fcmovne st(0), st(0)',  'fcmovne st(0), st(1)',  'fcmovne st(0), st(2)',  'fcmovne st(0), st(3)',
      'fcmovne st(0), st(4)',  'fcmovne st(0), st(5)',  'fcmovne st(0), st(6)',  'fcmovne st(0), st(7)',
      'fcmovnbe st(0), st(0)',  'fcmovnbe st(0), st(1)',  'fcmovnbe st(0), st(2)',  'fcmovnbe st(0), st(3)',
      'fcmovnbe st(0), st(4)',  'fcmovnbe st(0), st(5)',  'fcmovnbe st(0), st(6)',  'fcmovnbe st(0), st(7)',
      'fcmovnu st(0), st(0)',  'fcmovnu st(0), st(1)',  'fcmovnu st(0), st(2)',  'fcmovnu st(0), st(3)',
      'fcmovnu st(0), st(4)',  'fcmovnu st(0), st(5)',  'fcmovnu st(0), st(6)',  'fcmovnu st(0), st(7)',
      '%c ',               '%c ',               'fclex',          'finit',
      '%c ',               '%c ',               '%c ',               '%c ',
      'fucomi  st(0), st(0)',  'fucomi  st(0), st(1)',  'fucomi  st(0), st(2)',  'fucomi  st(0), st(3)',
      'fucomi  st(0), st(4)',  'fucomi  st(0), st(5)',  'fucomi  st(0), st(6)',  'fucomi  st(0), st(7)',
      'fcomi   st(0), st(0)',  'fcomi   st(0), st(1)',  'fcomi   st(0), st(2)',  'fcomi   st(0), st(3)',
      'fcomi   st(0), st(4)',  'fcomi   st(0), st(5)',  'fcomi   st(0), st(6)',  'fcomi   st(0), st(7)',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c '),
    // 'e'
     ('fadd    #Eq ',    'fmul    #Eq ',    'fcom    #Eq ',    'fcomp   #Eq ',
      'fsub    #Eq ',    'fsubr   #Eq ',    'fdiv    #Eq ',    'fdivr   #Eq ',
      'fadd    st(0), st(0)',  'fadd    st(1), st(0)',  'fadd    st(2), st(0)',  'fadd    st(3), st(0)',
      'fadd    st(4), st(0)',  'fadd    st(5), st(0)',  'fadd    st(6), st(0)',  'fadd    st(7), st(0)',
      'fmul    st(0), st(0)',  'fmul    st(1), st(0)',  'fmul    st(2), st(0)',  'fmul    st(3), st(0)',
      'fmul    st(4), st(0)',  'fmul    st(5), st(0)',  'fmul    st(6), st(0)',  'fmul    st(7), st(0)',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      'fsubr   st(0), st(0)',  'fsubr   st(1), st(0)',  'fsubr   st(2), st(0)',  'fsubr   st(3), st(0)',
      'fsubr   st(4), st(0)',  'fsubr   st(5), st(0)',  'fsubr   st(6), st(0)',  'fsubr   st(7), st(0)',
      'fsub    st(0), st(0)',  'fsub    st(1), st(0)',  'fsub    st(2), st(0)',  'fsub    st(3), st(0)',
      'fsub    st(4), st(0)',  'fsub    st(5), st(0)',  'fsub    st(6), st(0)',  'fsub    st(7), st(0)',
      'fdivr   st(0), st(0)',  'fdivr   st(1), st(0)',  'fdivr   st(2), st(0)',  'fdivr   st(3), st(0)',
      'fdivr   st(4), st(0)',  'fdivr   st(5), st(0)',  'fdivr   st(6), st(0)',  'fdivr   st(7), st(0)',
      'fdiv    st(0), st(0)',  'fdiv    st(1), st(0)',  'fdiv    st(2), st(0)',  'fdiv    st(3), st(0)',
      'fdiv    st(4), st(0)',  'fdiv    st(5), st(0)',  'fdiv    st(6), st(0)',  'fdiv    st(7), st(0)'),
    // 'f'
     ('fld     #Eq ',    '%c ',               'fst     #Eq ',    'fstp    #Eq ',
      'frstor  #E  ',    '%c ',               'fsave   #E  ',    'fstsw   #Ew ',
      'ffree   st(0)',  'ffree   st(1)',  'ffree   st(2)',  'ffree   st(3)',
      'ffree   st(4)',  'ffree   st(5)',  'ffree   st(6)',  'ffree   st(7)',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      'fst     st(0)',  'fst     st(1)',  'fst     st(2)',  'fst     st(3)',
      'fst     st(4)',  'fst     st(5)',  'fst     st(6)',  'fst     st(7)',
      'fstp    st(0)',  'fstp    st(1)',  'fstp    st(2)',  'fstp    st(3)',
      'fstp    st(4)',  'fstp    st(5)',  'fstp    st(6)',  'fstp    st(7)',
      'fucom   st(0), st(0)',  'fucom   st(1), st(0)',  'fucom   st(2), st(0)',  'fucom   st(3), st(0)',
      'fucom   st(4), st(0)',  'fucom   st(5), st(0)',  'fucom   st(6), st(0)',  'fucom   st(7), st(0)',
      'fucomp  st(0)',  'fucomp  st(1)',  'fucomp  st(2)',  'fucomp  st(3)',
      'fucomp  st(4)',  'fucomp  st(5)',  'fucomp  st(6)',  'fucomp  st(7)',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c '),
    // 'g'
     ('fiadd   #Ew ',    'fimul   #Ew ',    'ficom   #Ew ',    'ficomp  #Ew ',
      'fisub   #Ew ',    'fisubr  #Ew ',    'fidiv   #Ew ',    'fidivr  #Ew ',
      'faddp   st(0), st(0)',  'faddp   st(1), st(0)',  'faddp   st(2), st(0)',  'faddp   st(3), st(0)',
      'faddp   st(4), st(0)',  'faddp   st(5), st(0)',  'faddp   st(6), st(0)',  'faddp   st(7), st(0)',
      'fmulp   st(0), st(0)',  'fmulp   st(1), st(0)',  'fmulp   st(2), st(0)',  'fmulp   st(3), st(0)',
      'fmulp   st(4), st(0)',  'fmulp   st(5), st(0)',  'fmulp   st(6), st(0)',  'fmulp   st(7), st(0)',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               'fcompp',         '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      'fsubrp  st(0), st(0)',  'fsubrp  st(1), st(0)',  'fsubrp  st(2), st(0)',  'fsubrp  st(3), st(0)',
      'fsubrp  st(4), st(0)',  'fsubrp  st(5), st(0)',  'fsubrp  st(6), st(0)',  'fsubrp  st(7), st(0)',
      'fsubp   st(0), st(0)',  'fsubp   st(1), st(0)',  'fsubp   st(2), st(0)',  'fsubp   st(3), st(0)',
      'fsubp   st(4), st(0)',  'fsubp   st(5), st(0)',  'fsubp   st(6), st(0)',  'fsubp   st(7), st(0)',
      'fdivrp  st(0), st(0)',  'fdivrp  st(1), st(0)',  'fdivrp  st(2), st(0)',  'fdivrp  st(3), st(0)',
      'fdivrp  st(4), st(0)',  'fdivrp  st(5), st(0)',  'fdivrp  st(6), st(0)',  'fdivrp  st(7), st(0)',
      'fdivp   st(0), st(0)',  'fdivp   st(1), st(0)',  'fdivp   st(2), st(0)',  'fdivp   st(3), st(0)',
      'fdivp   st(4), st(0)',  'fdivp   st(5), st(0)',  'fdivp   st(6), st(0)',  'fdivp   st(7), st(0)'),
    // 'h'
     ('fild    #Ew ',    '%c ',               'fist    #Ew ',    'fistp   #Ew ',
      'fbld    #E  ',    'fild    #Eq ',    'fbstp   #E  ',    'fistp   #Eq ',        '%c ',                     '%c ',                     '%c ',                     '%c ',
      '%c ',                '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ' ,                    '%c ' ,                    '%c ' ,                    '%c ' ,
      '%c ',               '%c ',               '%c ',               '%c ',
      '%c ',                     '%c ',                     '%c ',                     '%c ',
      '%c ' ,                    '%c ' ,                    '%c ' ,                    '%c ' ,
      'fstsw   ax',     '%c ',               '%c ',               '%c ',
      '%c ',                     '%c ',                     '%c ',                     '%c ',
      'fucomip st(0), st(0)',  'fucomip st(0), st(1)',  'fucomip st(0), st(2)',  'fucomip st(0), st(3)',
      'fucomip st(0), st(4)',  'fucomip st(0), st(5)',  'fucomip st(0), st(6)',  'fucomip st(0), st(7)',      'fcomip  st(0), st(0)',  'fcomip  st(0), st(1)',  'fcomip  st(0), st(2)',  'fcomip  st(0), st(3)',
      'fcomip  st(0), st(4)',  'fcomip  st(0), st(5)',  'fcomip  st(0), st(6)', 'fcomip  st(0), st(7)',
      '%c ' ,                    '%c ' ,                    '%c ' ,                    '%c ' ,
      '%c ',               '%c ',               '%c ',               '%c '));

implementation

end.
