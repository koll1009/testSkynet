#ifndef _CRYPTO_H_
#define _CRYPTO_H_

int
hkdfExtract(const char *theSalt,
            int         theSaltLen,
            const char *theIkm,
            int         theIkmLen,
            char       *thePseudoRandomKey,
            int        *thePseudoRandomKeyLen);

int
hkdfExpand(const char*   thePrk,
           int           thePrkLen,
           const char*   theInfo,
           int           theInfoLen,
           size_t        theLength,
           char*         theResult);

int
hkdfExpandLabel(const char*   theSecret,
                int           theSecretLen,
                const char*   theLabel,
                int           theLabelLen,
                const char*   theContext,
                int           theContextLen,
                int           theLength,
                char*         theResult);
int
ecbEncrypt(const char*   thePlainText,
           int           thePlainTextLen,
           const char*   theKey,
           char*         theCipherText,
           int*          theCipherTextLen);



int
gcmDecrypt(const unsigned char* theCipherText,
           int                  theCipherTextLen,
           const unsigned char* theAad,
           int                  theAadLen,
           const unsigned char* theKey,
           const unsigned char* theIv,
           int                  theIvLen,
           const unsigned char* theTag,
           int                  theTagLen,
           int                  theSkipFinal,
           unsigned char*       thePlainText,
           int*                 thePlainTextLen);

#endif
