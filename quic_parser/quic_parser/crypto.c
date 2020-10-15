#include <openssl/hmac.h>
#include <string.h>
#include <stdlib.h>

int
hkdfExtract(const char *theSalt,
            int         theSaltLen,
            const char *theIkm,
            int         theIkmLen,
            char       *thePseudoRandomKey,
            int        *thePseudoRandomKeyLen)
{
    const EVP_MD* hashFunction = 0;

    unsigned char md[EVP_MAX_MD_SIZE];
    unsigned int md_len = 0;

    // calculate
    unsigned char* res = HMAC(EVP_sha256(),
                              theSalt,
                              theSaltLen,
                              theIkm,
                              theIkmLen,
                              md,
                              &md_len);

    if (res != 0)
    {
        memcpy(thePseudoRandomKey, res, md_len);
        *thePseudoRandomKeyLen = md_len;
        return 0;
    }

    return 1;
}

int
hkdfExpand(const char*   thePrk,
           int           thePrkLen,
           const char*   theInfo,
           int           theInfoLen,
           size_t        theLength,
           char*         theResult)
{
   int theResultLen = 0;
   size_t n = theLength / 32;
   if ((theLength % 32) > 0)
   {
      n++;
   }
   char t[EVP_MAX_MD_SIZE];
   int  tLen = 0;
   unsigned char* value = malloc(32 + theInfoLen + 1);
   for (unsigned int i = 1; i <= n; i++)
   {
      unsigned char md[EVP_MAX_MD_SIZE];
      unsigned int mdLength = 0;

      // calculate
      unsigned int valueLength = tLen;
      memcpy(value, t, valueLength);
      memcpy(value + valueLength, theInfo, theInfoLen);
      valueLength += theInfoLen;
      value[valueLength] = i;
      valueLength++;
      unsigned char* res = HMAC(EVP_sha256(),
                                thePrk,
                                thePrkLen,
                                value,
                                valueLength,
                                md, &mdLength);

      if (res == 0)
      {
         free(value);
         return 1;
      }

      memcpy(t, md, mdLength);
      tLen = mdLength;

      if (theResultLen + tLen > theLength)
      {
         tLen = theLength - theResultLen;
      }
      memcpy(theResult + theResultLen, t, tLen);
      theResultLen += tLen;
   }
   free(value);
   return 0;
}

int
hkdfExpandLabel(const char*   theSecret,
                int           theSecretLen,
                const char*   theLabel,
                int           theLabelLen,
                const char*   theContext,
                int           theContextLen,
                int           theLength,
                char*         theResult)
{
   char *hkdfLabel = malloc(10 + theLabelLen + theContextLen);
   int hkdfLabelLen = 0;;

   hkdfLabel[hkdfLabelLen++] = (theLength >> 8) & 0xFF;
   hkdfLabel[hkdfLabelLen++] = theLength & 0xFF;
   hkdfLabel[hkdfLabelLen++] = 6 + theLabelLen;
   memcpy(hkdfLabel + hkdfLabelLen, "tls13 ", 6);
   hkdfLabelLen += 6;
   memcpy(hkdfLabel + hkdfLabelLen, theLabel, theLabelLen);
   hkdfLabelLen += theLabelLen;
   hkdfLabel[hkdfLabelLen++] = theContextLen;

   if (theContextLen > 0)
   {
       memcpy(hkdfLabel + hkdfLabelLen, theContext, theContextLen);
       hkdfLabelLen += theContextLen;
   }

   int res = hkdfExpand(theSecret,
                        theSecretLen,
                        hkdfLabel,
                        hkdfLabelLen,
                        theLength,
                        theResult);
   free(hkdfLabel);
   return res;
}

int
ecbEncrypt(const char*   thePlainText,
           int           thePlainTextLen,
           const char*   theKey,
           char*         theCipherText,
           int*          theCipherTextLen)
{
   const EVP_CIPHER* cipher = EVP_aes_128_ecb();
   EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
   if (ctx == 0)
   {
      return 1;
   }
   EVP_CIPHER_CTX_init(ctx);
   if (EVP_EncryptInit_ex(ctx,
                          cipher,
                          NULL,
                          theKey,
                          NULL) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      return 2;
   }
   EVP_CIPHER_CTX_set_padding(ctx, 0);

   unsigned char* buffer = malloc(thePlainTextLen + EVP_CIPHER_block_size(cipher));
   unsigned char* pointer = buffer;
   int outlen;
   if (EVP_EncryptUpdate(ctx,
                         pointer,
                         &outlen,
                         thePlainText,
                         thePlainTextLen) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      free(buffer);
      return 3;
   }

   pointer += outlen;
   if (EVP_EncryptFinal_ex(ctx,
                           pointer,
                           &outlen) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      free(buffer);
      return 4;
   }

   pointer += outlen;
   memcpy(theCipherText, buffer, pointer - buffer);
   *theCipherTextLen = pointer - buffer;

   // Clean up
   EVP_CIPHER_CTX_free(ctx);
   free(buffer);
   return 0;
}

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
           int*                 thePlainTextLen)
{
   EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
   if (ctx == 0)
   {
      return 1;
   }

   // Initialize the encryption operation.
   const EVP_CIPHER* cipher = EVP_aes_128_gcm();
   if (EVP_EncryptInit_ex(ctx,
                          cipher,
                          NULL,
                          NULL,
                          NULL) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      return 2;
   }

   // Set IV length. Not necessary if this is 12 bytes (96 bits)
   if (EVP_CIPHER_CTX_ctrl(ctx,
                           EVP_CTRL_GCM_SET_IVLEN,
                           theIvLen,
                           NULL) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      return 3;
   }

   // Initialize key and IV
   if (EVP_DecryptInit_ex(ctx,
                          NULL,
                          NULL,
                          theKey,
                          theIv) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      return 4;
   }

   // Provide any AAD data. This can be called zero or more times as required
   int aadlen;
   if (theAadLen > 0)
   {
      if (EVP_DecryptUpdate(ctx,
                            NULL,
                            &aadlen,
                            theAad,
                            theAadLen) == 0)
      {
         EVP_CIPHER_CTX_free(ctx);
         return 5;
      }
   }

   unsigned char* buffer = malloc(theCipherTextLen + EVP_CIPHER_block_size(cipher));
   unsigned char* pointer = buffer;
   int outlen;

   // Provide the message to be decrypted, and obtain the plaintext output.
   // EVP_DecryptUpdate can be called multiple times if necessary
   if (EVP_DecryptUpdate(ctx,
                         pointer,
                         &outlen,
                         theCipherText,
                         theCipherTextLen) == 0)
   {
      EVP_CIPHER_CTX_free(ctx);
      free(buffer);
      return 6;
   }

   pointer += outlen;

   // Set expected tag value. Works in OpenSSL 1.0.1d and later
   if (theTagLen == 16)
   {
      if (EVP_CIPHER_CTX_ctrl(ctx,
                              EVP_CTRL_GCM_SET_TAG,
                              16,
                              (void*)theTag) == 0)
      {
         EVP_CIPHER_CTX_free(ctx);
         free(buffer);
         return 7;
      }
   }
   else
   {
      if (theTagLen != 0)
      {
         EVP_CIPHER_CTX_free(ctx);
         free(buffer);
         return 8;
      }
   }

   // Finalize the decryption. A positive return value indicates success,
   // anything else is a failure - the plaintext is not trustworthy.
   if (theSkipFinal == 0)
   {
      if (EVP_DecryptFinal_ex(ctx,
                              pointer,
                              &outlen) == 0)
      {
         EVP_CIPHER_CTX_free(ctx);
         free(buffer);
         return 9;
      }

      pointer += outlen;
   }

   memcpy(thePlainText, buffer, pointer - buffer);
   *thePlainTextLen = pointer - buffer;

   // Clean up
   EVP_CIPHER_CTX_free(ctx);
   free(buffer);
   return 0;
}


