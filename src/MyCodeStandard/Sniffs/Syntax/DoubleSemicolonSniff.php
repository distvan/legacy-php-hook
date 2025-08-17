<?php

namespace MyCodeStandard\Sniffs\Syntax;

use PHP_CodeSniffer\Sniffs\Sniff;
use PHP_CodeSniffer\Files\File;

class DoubleSemicolonSniff implements Sniff
{
    public function register(): array
    {
        return [T_SEMICOLON];
    }

    public function process(File $phpcsFile, $stackPtr): void
    {
        $tokens = $phpcsFile->getTokens();
        // Check if the current semicolon is followed by another semicolon on the same line
        $next = $stackPtr + 1;
        if (isset($tokens[$next]) && $tokens[$next]['code'] === T_SEMICOLON) {
            $phpcsFile->addError(
                'Double semicolon found on line %s',
                $stackPtr,
                'DoubleSemicolon',
            );
        }
    }
}
