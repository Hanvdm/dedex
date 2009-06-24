----------------------------
- DeDe ver 3.01 by DaFixer -
----------------------------


What is DeDe?
-------------

  DeDe is a very fast program that can analize executables compiled with Delphi 3,4,5,6, C++Builder and Kylix and give you the following:

  - All dfm files of the target. You will be able to open and edit them with Delphi
  - All published methods in well commented ASM code with references to strings, imported function calls, classes methods calls, components in the unit, Try-Except and Try-Finally blocks. By default DeDe retreives only the published methods sources, but you may also process another procedure in a executable if you know the RVA offset using the Tools|Disassemble Proc menu
  - A lot of additional information.
  - You can create a Delphi project folder with all dfm, pas, dpr files. Note: pas files contains the mentioned above well commented ASM code. They can not be recompiled !

  You can also:

  - Dump and process active processes from memory.
  - Use the Entry Point find utility to find the real entry point of every packed Delphi2-Delphi6 program
  - View the PE Header of all PE Files and change/edit the sections flags
  - Use the opcode-to-asm tool for translating intel opcode to assembler
  - Use RVA-to-PhysOffset tool for fast converting physical and RVA addresses
  - Use the DCU Dumper (view dcu2int.txt for more details) to retreive near to pascal code of your DCU files
  - Use BPL Dumper to see BPL exports and create symbol files to use with DeDe Disassembler


What are DeDe Symbol Files (DSF) ?
----------------------------------

  DSF files contain the symbols of the exports from different BPL libraries. DeDe disassemble engine use this symbol files to comment the class members method calls in ASM source it generates. The ideology is very close to the IDA symbol files for VCL, MFC etc. 
  If you haven't loaded a symbol file for any BPL you'll not get references to calls to this BPL classes!

How to load DSF Files?
----------------------

  You can load a DSF file using File|Load Symbol File menu selecting the dsf file. If you want some dsf files to be loaded automaticly each time DeDe is loaded use the View|Configuration menu and from Symbols tab manage the dsf that should be loaded  at startup of DeDe. If you want to see the names of exports that are contained in a certain DSF file use the View|Symbols menu.

How to create DSF Files?
------------------------

  You can create a DSF files from the BPL Dumber symbols tab. Choose the bpl (note that you should have all required bpl for the selected one, if any) then choose the dsf file name. Before generating you can select what should be done with the export names. You can fix their names and/or parameters. If you do this DeDe will change the default export names from the bpl with more readable ones. After creating the DSF you should load it in order to use it.

Why should I create DSF files?
------------------------------

  Because if you deal with a program that uses custom components and you have the components BPLs if you create a DSF for these components DeDe will comment for you all the calls to those comonents. Nice uh? :) Also the creation of DSFs is very fast.

What is this "Show All Found DSF References" check box in the configuration form?
---------------------------------------------------------------------------------

  Recognizing of a procedure calls is made by comparing bytes. Sometimes (depending how many DSFs you have loaded) there are more than one procedure with the same byte pattern. In this case DeDe is unable to determine exactly whitch one is called. If you check this option DeDe will show you all references if it finds more than one. If this is unchecked you will see only the first found reference. Note: The search orded is by the order of loaded DSFs and then alphabeticaly by unit name, class name, procedure name.

What is this "String References" option in configuration form?
--------------------------------------------------------------

  Normaly programs like W32DASM for example search only for english string references. If you deal with a program that has other language strings then from here you can choose the set of chars DeDe disassemble engine will search string references. Note: You may have invalid referencec if you use the full set #32-#255. Note: delphi programs normaly do not use UNICODE strings and thats why this option is not included in string references configuration.
  

Why DeDe says this is not a Delphi program when I am sure it is ?
-----------------------------------------------------------------

  1-st make sure the target is not packed or crypted
  2-nd if you have unpacked/dumped the target make sure it has a valid entry point. You can use the Entry Point find utility or Tools|PE Header Correct to let DeDe to correct the program entry point.
  
  If you are sure the target is OK and it is a delphi program that DeDe can not process then I will appreciate if you send me a mail with your target name and problem description.


Whitch packers DeDe Supports ?
------------------------------

   Supported packers: BJFNT, CodeSafe, PCShrink, PE-Crypt, PELockNT, PEPack, Petite, Shrinker, WWWPack, Armadillo (must dump the xxx.tmp not xxx.exe), Aspack. 
   Not supported for now are: NeoLite and UPX. Please tell me if you find more!


How can I register ?
--------------------

  DeDe is a free software and you have no need to register it neither to crack it :) It has its full functionality!


How can I reach the author?
---------------------------

  d_Fixer@hotmail.com