RxLib Component library Delphi VCL Extensions (RX) Library, 
was developed by Fedor Kozhevnikov, Sergey Korolev and Igor 
Pavlyuk. This is free open source product that was very popular
among Delphi developers in ex-USSR and world.

Project development was stopped. Library was included in 
JEDI Visual Component Library. 
Homepage: http://homepages.borland.com/jedi/jvcl/

My own adaptation for 2009-2010. Highlights.
=====================================================================

I DO NOT GUARANTEE that EVERYTHING WAS CONVERTED!!! But...

I checked correctness of use of string types (string, Char, PCHar) in
every place where i found those types. Especially in the case of using 
them as buffers. 
These unites where changed especially hard:

1. Unit RxRichEd.pas:
  - completely reworked methods of internal class TRichEditStrings 
    that work with files/streams LoadFromFile, LoadFromStream, 
    SaveToFile, SaveToStream accordingly to new features of CG2009 
    (to support overridden methods with parameter Encoding: TEncoding)
  - Property TRxCustomRichEdit.StreamMode - for CG2009 flag smUnicode  
    was excluded from tje set of available:   
    TRichStreamMode = (smSelection, smPlainRtf, 
                       smNoObjects{$IFNDEF RX_D12}, smUnicode{$ENDIF});
    TRichStreamModes = set of TRichStreamMode;
    Herewith, appropriate mode was enabled by default for the class 
    TRichEditStrings.

2. Unit rxDbutils.pas:
  - replaced types:
    TBookmark replaced Pointer;
    TBookmarkStr replaced TBookmark;
    PChar replaced TRecordBuffer (where it had sense). 
    Syntax:
    {$IFDEF RX_D12}
      TBookmarkType = TBookmark;
      TBookmarkPointerType = Pointer;
      TBuffer = TRecordBuffer;
    {$ELSE}
      TBookmarkType = TBookmarkStr;
      TBookmarkPointerType = TBookmark;
      TBuffer = PChar;
    {$ENDIF}
    These types where replaced by TBookmarkType, TBuffer, 
	TBookmarkPointerType in sources to keep compatibility with 
	previous Delphi versions.

3. Unit RxMemDS.pas:
  - replaced types (similar to 2):
    {$IFDEF RX_D12}
      TBlobDataArray = array of TBlobData;
      TBlobDataArrayType = TBlobDataArray;
      TBlobDataType = TBlobData;
    {$ELSE}
      TMemBlobData = AnsiString;
      TMemBlobArray = array[0..0] of TMemBlobData;
      TBlobDataArrayType = ^TMemBlobArray;
      TBlobDataType = TMemBlobData;
      PMemBlobArray = ^TMemBlobArray;
    {$ENDIF}   
    
4. Unit rxCheckItm.pas:
  - fixed error in property editor Items of component CheckListBox.

Result: 
- Packages compiled without errors, hints and warnings. 
- Demo projects Rxdemo, Riched2, Gifanm32 compiled and work fine.
  Other demos have been outdated too much, so I did not fix them...
- My working projects work fine.

===============================================================
Adaptation: psa1974 
Feedback:
http://forum.ru-board.com/
http://www.dumpz.ru/
http://www.nowa.cc
