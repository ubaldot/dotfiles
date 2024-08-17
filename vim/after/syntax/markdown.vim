
syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" keepend contained conceal contains=markdownUrl
syn match markdownExt /{[.:#][^}]*}/ conceal contains=ALL

syn region markdownLinkText matchgroup=markdownLinkTextDelimiter
    \ start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@="
    \ nextgroup=markdownLink,markdownId skipwhite
    \ contains=@markdownInline,markdownLineStart
    \ concealends
