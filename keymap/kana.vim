" This script was originally created by Rory McCann <ebelular at gmail dot com>.
" Dan Kenigsberg noticed some deficiencies and suggested this one instead.
"
" Maintainer: Rory McCann <ebelular at gmail dot com>
" Last Change: 1st February 2005
"
"
"
"  Kana.kmap (Japanese Phonograms)
"
"  Converted from Gaspar Sinai's yudit 2.7.6
"  GNU (C) Gaspar Sinai <gsinai@yudit.org>
"
"  WARNING
"  -------
"  This version of Kana.kmap is different from the one that has been used
"  with yudit-2.7.2 or earlier.  The main difference is that this kmap is
"  arranged in such a way that it complies with an authorized Japanese
"  transliteration.  As a result, backward compatibility is not guaranteed.
"
"  NOTE
"  ----
"  1.	In general, the transliteration is based on Japanese Government's
"	Cabinet	Notification 1 (Dec. 9, 1954).
"
"	Summary:
"
"	(1) To transliterate Japanese language, Table 1 should be used
"          primarily.
"	(2) Table 2 may be used only when existing conventions such as
"          international relationship should be respected.
"	(3) Other transliteration is acceptable only when neither Table 1
"	    nor Table 2 gives any specification of the sound in question
"
"	For details, refer to
"
"	    http://xembho.tripod.com/siryo/naikaku_kokuzi.html
"
"  2.	The specification instructed by the Cabinet Notification is rather
"	inadequate even for daily use.  At the present time there are thus
"	many unauthorized but widely accepted conventions used together with
"	the authorized transliteration.  This kmap contains some of them for
"	user's convenience (cf. Hiragana 3 and Katakana 3).
"
"  3.	For the unicode mapping relevant to this kmap, refer to	3075--30F5 of
"
"	    http://www.macchiato.com/unicode/charts.html
"
"  HISTORY
"  -------
"  2005-01-11	<danken@cs.technion.ac.il>
"	* Converted to Vim format.
"  2003-01-22	<kazunobu.kuriyama@nifty.com>
"
"	* Submitted to gsinai@yudit.org
"
" ============================================================================


" ----------------------------------------------------------------------------
"  Kigou (Punctuation etc.)
" ----------------------------------------------------------------------------

let b:keymap_name = "kana"

loadkeymap
"0x20  0x3000
, <char-0x3001>
. <char-0x3002>
,, <char-0x3003>


xx <char-0x3006>
@ <char-0x3007>
< <char-0x3008>
> <char-0x3009>
<< <char-0x300A>
>> <char-0x300B>
{ <char-0x300C>
} <char-0x300D>
{{ <char-0x300E>
}} <char-0x300F>
[.( <char-0x3010>
).] <char-0x3011>


[ <char-0x3014>
] <char-0x3015>
[( <char-0x3016>
)] <char-0x3017>


[[ <char-0x301A>
]] <char-0x301B>


.. <char-0x30FB>
- <char-0x30FC>


" ----------------------------------------------------------------------------
"  Hiragana 1 --- Table 1, Cabinet Notification No. 1 (Dec. 9, 1954)
" ----------------------------------------------------------------------------
a <char-0x3042>
i <char-0x3044>
u <char-0x3046>
e <char-0x3048>
o <char-0x304A>

ka <char-0x304B>
ki <char-0x304D>
ku <char-0x304F>
ke <char-0x3051>
ko <char-0x3053>

sa <char-0x3055>
si <char-0x3057>
su <char-0x3059>
se <char-0x305B>
so <char-0x305D>

ta <char-0x305F>
ti <char-0x3061>
tu <char-0x3064>
te <char-0x3066>
to <char-0x3068>

na <char-0x306A>
ni <char-0x306B>
nu <char-0x306C>
ne <char-0x306D>
no <char-0x306E>

ha <char-0x306F>
hi <char-0x3072>
hu <char-0x3075>
he <char-0x3078>
ho <char-0x307B>

ma <char-0x307E>
mi <char-0x307F>
mu <char-0x3080>
me <char-0x3081>
mo <char-0x3082>

ya <char-0x3084>
yu <char-0x3086>
yo <char-0x3088>

ra <char-0x3089>
ri <char-0x308A>
ru <char-0x308B>
re <char-0x308C>
ro <char-0x308D>

wa <char-0x308F>

ga <char-0x304C>
gi <char-0x304E>
gu <char-0x3050>
ge <char-0x3052>
go <char-0x3054>

za <char-0x3056>
zi <char-0x3058>
zu <char-0x305A>
ze <char-0x305C>
zo <char-0x305E>

da <char-0x3060>
de <char-0x3067>
do <char-0x3069>

ba <char-0x3070>
bi <char-0x3073>
bu <char-0x3076>
be <char-0x3079>
bo <char-0x307C>

pa <char-0x3071>
pi <char-0x3074>
pu <char-0x3077>
pe <char-0x307A>
po <char-0x307D>

kya <char-0x304D><char-0x3083>
kyu <char-0x304D><char-0x3085>
kyo <char-0x304D><char-0x3087>

sya <char-0x3057><char-0x3083>
syu <char-0x3057><char-0x3085>
syo <char-0x3057><char-0x3087>

tya <char-0x3061><char-0x3083>
tyu <char-0x3061><char-0x3085>
tyo <char-0x3061><char-0x3087>

nya <char-0x306B><char-0x3083>
nyu <char-0x306B><char-0x3085>
nyo <char-0x306B><char-0x3087>

hya <char-0x3072><char-0x3083>
hyu <char-0x3072><char-0x3085>
hyo <char-0x3072><char-0x3087>

mya <char-0x307F><char-0x3083>
myu <char-0x307F><char-0x3085>
myo <char-0x307F><char-0x3087>

rya <char-0x308A><char-0x3083>
ryu <char-0x308A><char-0x3085>
ryo <char-0x308A><char-0x3087>

gya <char-0x304E><char-0x3083>
gyu <char-0x304E><char-0x3085>
gyo <char-0x304E><char-0x3087>

zya <char-0x3058><char-0x3083>
zyu <char-0x3058><char-0x3085>
zyo <char-0x3058><char-0x3087>

bya <char-0x3073><char-0x3083>
byu <char-0x3073><char-0x3085>
byo <char-0x3073><char-0x3087>

pya <char-0x3074><char-0x3083>
pyu <char-0x3074><char-0x3085>
pyo <char-0x3074><char-0x3087>

n <char-0x3093>
n' <char-0x3093>


" ----------------------------------------------------------------------------
"  Hiragana 2 --- Table 2, Cabinet Notification No. 1 (Dec. 9, 1954)
" ----------------------------------------------------------------------------
sha <char-0x3057><char-0x3083>
shi <char-0x3057>
shu <char-0x3057><char-0x3085>
sho <char-0x3057><char-0x3087>

tsu <char-0x3064>

cha <char-0x3061><char-0x3083>
chi <char-0x3061>
chu <char-0x3061><char-0x3085>
cho <char-0x3061><char-0x3087>

fu <char-0x3075>

ja <char-0x3058><char-0x3083>
ji <char-0x3058>
ju <char-0x3058><char-0x3085>
jo <char-0x3058><char-0x3087>

di <char-0x3062>
du <char-0x3065>
dya <char-0x3062><char-0x3083>
dyu <char-0x3062><char-0x3085>
dyo <char-0x3062><char-0x3087>

kwa <char-0x304F><char-0x308E>
gwa <char-0x3050><char-0x308E>

wo <char-0x3092>


" ----------------------------------------------------------------------------
"  Hiragana 3 --- Conventional transliterations
" ----------------------------------------------------------------------------

" Small Hiragana: The prefix X is never pronounced.  It is used as something
" like an escape character.
xa <char-0x3041>
xi <char-0x3043>
xu <char-0x3045>
xe <char-0x3047>
xo <char-0x3049>

xtu <char-0x3063>

xya <char-0x3083>
xyu <char-0x3085>
xyo <char-0x3087>

xwa <char-0x308E>

" Historic `wi' and `we'
wi <char-0x3090>
we <char-0x3091>

" Preceded by a small `tu'
kka <char-0x3063><char-0x304B>
kki <char-0x3063><char-0x304D>
kku <char-0x3063><char-0x304F>
kke <char-0x3063><char-0x3051>
kko <char-0x3063><char-0x3053>

ssa <char-0x3063><char-0x3055>
ssi <char-0x3063><char-0x3057>
ssu <char-0x3063><char-0x3059>
sse <char-0x3063><char-0x305B>
sso <char-0x3063><char-0x305D>

tta <char-0x3063><char-0x305F>
tti <char-0x3063><char-0x3061>
ttu <char-0x3063><char-0x3064>
tte <char-0x3063><char-0x3066>
tto <char-0x3063><char-0x3068>

hha <char-0x3063><char-0x306F>
hhi <char-0x3063><char-0x3072>
hhu <char-0x3063><char-0x3075>
hhe <char-0x3063><char-0x3078>
hho <char-0x3063><char-0x307B>

mma <char-0x3063><char-0x307E>
mmi <char-0x3063><char-0x307F>
mmu <char-0x3063><char-0x3080>
mme <char-0x3063><char-0x3081>
mmo <char-0x3063><char-0x3082>

yya <char-0x3063><char-0x3084>
yyu <char-0x3063><char-0x3086>
yyo <char-0x3063><char-0x3088>

rra <char-0x3063><char-0x3089>
rri <char-0x3063><char-0x308A>
rru <char-0x3063><char-0x308B>
rre <char-0x3063><char-0x308C>
rro <char-0x3063><char-0x308D>

wwa <char-0x3063><char-0x308F>

gga <char-0x3063><char-0x304C>
ggi <char-0x3063><char-0x304E>
ggu <char-0x3063><char-0x3050>
gge <char-0x3063><char-0x3052>
ggo <char-0x3063><char-0x3054>

zza <char-0x3063><char-0x3056>
zzi <char-0x3063><char-0x3058>
zzu <char-0x3063><char-0x305A>
zze <char-0x3063><char-0x305C>
zzo <char-0x3063><char-0x305E>

dda <char-0x3063><char-0x3060>
ddi <char-0x3063><char-0x3062>
ddu <char-0x3063><char-0x3065>
dde <char-0x3063><char-0x3067>
ddo <char-0x3063><char-0x3069>

bba <char-0x3063><char-0x3070>
bbi <char-0x3063><char-0x3073>
bbu <char-0x3063><char-0x3076>
bbe <char-0x3063><char-0x3079>
bbo <char-0x3063><char-0x307C>

ppa <char-0x3063><char-0x3071>
ppi <char-0x3063><char-0x3074>
ppu <char-0x3063><char-0x3077>
ppe <char-0x3063><char-0x307A>
ppo <char-0x3063><char-0x307D>

" Proceded by a small `tu' and followed by a small 'ya', 'yu' or 'yo'
kkya <char-0x3063><char-0x304D><char-0x3083>
kkyu <char-0x3063><char-0x304D><char-0x3085>
kkyo <char-0x3063><char-0x304D><char-0x3087>

ssya <char-0x3063><char-0x3057><char-0x3083>
ssyu <char-0x3063><char-0x3057><char-0x3085>
ssyo <char-0x3063><char-0x3057><char-0x3087>

ttya <char-0x3063><char-0x3061><char-0x3083>
ttyu <char-0x3063><char-0x3061><char-0x3085>
ttyo <char-0x3063><char-0x3061><char-0x3087>

hhya <char-0x3063><char-0x3072><char-0x3083>
hhyu <char-0x3063><char-0x3072><char-0x3085>
hhyo <char-0x3063><char-0x3072><char-0x3087>

mmya <char-0x3063><char-0x307F><char-0x3083>
mmyu <char-0x3063><char-0x307F><char-0x3085>
mmyo <char-0x3063><char-0x307F><char-0x3087>

rrya <char-0x3063><char-0x308A><char-0x3083>
rryu <char-0x3063><char-0x308A><char-0x3085>
rryo <char-0x3063><char-0x308A><char-0x3087>

ggya <char-0x3063><char-0x304E><char-0x3083>
ggyu <char-0x3063><char-0x304E><char-0x3085>
ggyo <char-0x3063><char-0x304E><char-0x3087>

zzya <char-0x3063><char-0x3058><char-0x3083>
zzyu <char-0x3063><char-0x3058><char-0x3085>
zzyo <char-0x3063><char-0x3058><char-0x3087>

bbya <char-0x3063><char-0x3073><char-0x3083>
bbyu <char-0x3063><char-0x3073><char-0x3085>
bbyo <char-0x3063><char-0x3073><char-0x3087>

ppya <char-0x3063><char-0x3074><char-0x3083>
ppyu <char-0x3063><char-0x3074><char-0x3085>
ppyo <char-0x3063><char-0x3074><char-0x3087>


" ----------------------------------------------------------------------------
"  Katakana 1 --- Table 1, Cabinet Notification No. 1 (Dec. 9, 1954)
" ----------------------------------------------------------------------------
A <char-0x30A2>
I <char-0x30A4>
U <char-0x30A6>
E <char-0x30A8>
O <char-0x30AA>

KA <char-0x30AB>
KI <char-0x30AD>
KU <char-0x30AF>
KE <char-0x30B1>
KO <char-0x30B3>

SA <char-0x30B5>
SI <char-0x30B7>
SU <char-0x30B9>
SE <char-0x30BB>
SO <char-0x30BD>

TA <char-0x30BF>
TI <char-0x30C1>
TU <char-0x30C4>
TE <char-0x30C6>
TO <char-0x30C8>

NA <char-0x30CA>
NI <char-0x30CB>
NU <char-0x30CC>
NE <char-0x30CD>
NO <char-0x30CE>

HA <char-0x30CF>
HI <char-0x30D2>
HU <char-0x30D5>
HE <char-0x30D8>
HO <char-0x30DB>

MA <char-0x30DE>
MI <char-0x30DF>
MU <char-0x30E0>
ME <char-0x30E1>
MO <char-0x30E2>

YA <char-0x30E4>
YU <char-0x30E6>
YO <char-0x30E8>

RA <char-0x30E9>
RI <char-0x30EA>
RU <char-0x30EB>
RE <char-0x30EC>
RO <char-0x30ED>

WA <char-0x30EF>

GA <char-0x30AC>
GI <char-0x30AE>
GU <char-0x30B0>
GE <char-0x30B2>
GO <char-0x30B4>

ZA <char-0x30B6>
ZI <char-0x30B8>
ZU <char-0x30BA>
ZE <char-0x30BC>
ZO <char-0x30BE>

DA <char-0x30C0>
DE <char-0x30C7>
DO <char-0x30C9>

BA <char-0x30D0>
BI <char-0x30D3>
BU <char-0x30D6>
BE <char-0x30D9>
BO <char-0x30DC>

PA <char-0x30D1>
PI <char-0x30D4>
PU <char-0x30D7>
PE <char-0x30DA>
PO <char-0x30DD>

KYA <char-0x30AD><char-0x30E3>
KYU <char-0x30AD><char-0x30E5>
KYO <char-0x30AD><char-0x30E7>

SYA <char-0x30B7><char-0x30E3>
SYU <char-0x30B7><char-0x30E5>
SYO <char-0x30B7><char-0x30E7>

TYA <char-0x30C1><char-0x30E3>
TYU <char-0x30C1><char-0x30E5>
TYO <char-0x30C1><char-0x30E7>

NYA <char-0x30CB><char-0x30E3>
NYU <char-0x30CB><char-0x30E5>
NYO <char-0x30Cb><char-0x30E7>

HYA <char-0x30D2><char-0x30E3>
HYU <char-0x30D2><char-0x30E5>
HYO <char-0x30D2><char-0x30E7>

MYA <char-0x30DF><char-0x30E3>
MYU <char-0x30DF><char-0x30E5>
MYO <char-0x30DF><char-0x30E7>

RYA <char-0x30EA><char-0x30E3>
RYU <char-0x30EA><char-0x30E5>
RYO <char-0x30EA><char-0x30E7>

GYA <char-0x30AE><char-0x30E3>
GYU <char-0x30AE><char-0x30E5>
GYO <char-0x30AE><char-0x30E7>

ZYA <char-0x30B8><char-0x30E3>
ZYU <char-0x30B8><char-0x30E5>
ZYO <char-0x30B8><char-0x30E7>

BYA <char-0x30D3><char-0x30E3>
BYU <char-0x30D3><char-0x30E5>
BYO <char-0x30D3><char-0x30E7>

PYA <char-0x30D4><char-0x30E3>
PYU <char-0x30D4><char-0x30E5>
PYO <char-0x30D4><char-0x30E7>

N <char-0x30F3>
N' <char-0x30F3>


" ----------------------------------------------------------------------------
"  Katakana 2 --- Table 2, Cabinet Notification No. 1 (Dec. 9, 1954)
" ----------------------------------------------------------------------------
SHA <char-0x30B7><char-0x30E3>
SHI <char-0x30B7>
SHU <char-0x30B7><char-0x30E5>
SHO <char-0x30B7><char-0x30E7>

TSU <char-0x30C4>

CHA <char-0x30C1><char-0x30E3>
CHI <char-0x30C1>
CHU <char-0x30C1><char-0x30E5>
CHO <char-0x30C1><char-0x30E7>

FU <char-0x30D5>

JA <char-0x30B8><char-0x30E3>
JI <char-0x30B8>
JU <char-0x30B8><char-0x30E5>
JO <char-0x30B8><char-0x30E7>

DI <char-0x30C2>
DU <char-0x30C5>
DYA <char-0x30C2><char-0x30E3>
DYU <char-0x30C2><char-0x30E5>
DYO <char-0x30C2><char-0x30E7>

KWA <char-0x30AF><char-0x30EE>
GWA <char-0x30B0><char-0x30EE>

WO <char-0x30F2>


" ----------------------------------------------------------------------------
"  Katakana 3 --- Conventional transliterations
" ----------------------------------------------------------------------------

" Small Katakana: The prefix X is never pronounced.  It is used as something
" like an escape character.
XA <char-0x30A1>
XI <char-0x30A3>
XU <char-0x30A5>
XE <char-0x30A7>
XO <char-0x30A9>

XTU <char-0x30C3>

XYA <char-0x30E3>
XYU <char-0x30E5>
XYO <char-0x30E7>

XWA <char-0x30EE>

" Used only for counting someone or something
XKA <char-0x30F5>
XKE <char-0x30F6>

" Historic `wi' and `we'
WI <char-0x30F0>
WE <char-0x30F1>

" Used for the sound `v' of European languages
VA <char-0x30F4><char-0x30A1>
VI <char-0x30F4><char-0x30A3>
VU <char-0x30F4>
VE <char-0x30F4><char-0x30A7>
VO <char-0x30F4><char-0x30A9>

VYU <char-0x30F4><char-0x30E5>

" Preceded by a small `tu'
KKA <char-0x30C3><char-0x30AB>
KKI <char-0x30C3><char-0x30AD>
KKU <char-0x30C3><char-0x30AF>
KKE <char-0x30C3><char-0x30B1>
KKO <char-0x30C3><char-0x30B3>

SSA <char-0x30C3><char-0x30B5>
SSI <char-0x30C3><char-0x30B7>
SSU <char-0x30C3><char-0x30B9>
SSE <char-0x30C3><char-0x30BB>
SSO <char-0x30C3><char-0x30BD>

TTA <char-0x30C3><char-0x30BF>
TTI <char-0x30C3><char-0x30C1>
TTU <char-0x30C3><char-0x30C4>
TTE <char-0x30C3><char-0x30C6>
TTO <char-0x30C3><char-0x30C8>

HHA <char-0x30C3><char-0x30CF>
HHI <char-0x30C3><char-0x30D2>
HHU <char-0x30C3><char-0x30D5>
HHE <char-0x30C3><char-0x30D8>
HHO <char-0x30C3><char-0x30DB>

MMA <char-0x30C3><char-0x30DE>
MMI <char-0x30C3><char-0x30DF>
MMU <char-0x30C3><char-0x30E0>
MME <char-0x30C3><char-0x30E1>
MMO <char-0x30C3><char-0x30E2>

YYA <char-0x30C3><char-0x30E4>
YYU <char-0x30C3><char-0x30E6>
YYO <char-0x30C3><char-0x30E8>

RRA <char-0x30C3><char-0x30E9>
RRI <char-0x30C3><char-0x30EA>
RRU <char-0x30C3><char-0x30EB>
RRE <char-0x30C3><char-0x30EC>
RRO <char-0x30C3><char-0x30ED>

WWA <char-0x30C3><char-0x30EF>

GGA <char-0x30C3><char-0x30AC>
GGI <char-0x30C3><char-0x30AE>
GGU <char-0x30C3><char-0x30B0>
GGE <char-0x30C3><char-0x30B2>
GGO <char-0x30C3><char-0x30B4>

ZZA <char-0x30C3><char-0x30B6>
ZZI <char-0x30C3><char-0x30B8>
ZZU <char-0x30C3><char-0x30BA>
ZZE <char-0x30C3><char-0x30BC>
ZZO <char-0x30C3><char-0x30BE>

DDA <char-0x30C3><char-0x30C0>
DDI <char-0x30C3><char-0x30C2>
DDU <char-0x30C3><char-0x30C5>
DDE <char-0x30C3><char-0x30C7>
DDO <char-0x30C3><char-0x30C9>

BBA <char-0x30C3><char-0x30D0>
BBI <char-0x30C3><char-0x30D3>
BBU <char-0x30C3><char-0x30D6>
BBE <char-0x30C3><char-0x30D9>
BBO <char-0x30C3><char-0x30DC>

PPA <char-0x30C3><char-0x30D1>
PPI <char-0x30C3><char-0x30D4>
PPU <char-0x30C3><char-0x30D7>
PPE <char-0x30C3><char-0x30DA>
PPO <char-0x30C3><char-0x30DD>

" Proceded by a small `tu' and followed by a small 'ya', 'yu' or 'yo'
KKYA <char-0x30C3><char-0x30AD><char-0x30E3>
KKYU <char-0x30C3><char-0x30AD><char-0x30E5>
KKYO <char-0x30C3><char-0x30AD><char-0x30E7>

SSYA <char-0x30C3><char-0x30B7><char-0x30E3>
SSYU <char-0x30C3><char-0x30B7><char-0x30E5>
SSYO <char-0x30C3><char-0x30B7><char-0x30E7>

TTYA <char-0x30C3><char-0x30C1><char-0x30E3>
TTYU <char-0x30C3><char-0x30C1><char-0x30E5>
TTYO <char-0x30C3><char-0x30C1><char-0x30E7>

HHYA <char-0x30C3><char-0x30D2><char-0x30E3>
HHYU <char-0x30C3><char-0x30D2><char-0x30E5>
HHYO <char-0x30C3><char-0x30D2><char-0x30E7>

MMYA <char-0x30C3><char-0x30DF><char-0x30E3>
MMYU <char-0x30C3><char-0x30DF><char-0x30E5>
MMYO <char-0x30C3><char-0x30DF><char-0x30E7>

RRYA <char-0x30C3><char-0x30EA><char-0x30E3>
RRYU <char-0x30C3><char-0x30EA><char-0x30E5>
RRYO <char-0x30C3><char-0x30EA><char-0x30E7>

GGYA <char-0x30C3><char-0x30AE><char-0x30E3>
GGYU <char-0x30C3><char-0x30AE><char-0x30E5>
GGYO <char-0x30C3><char-0x30AE><char-0x30E7>

ZZYA <char-0x30C3><char-0x30B8><char-0x30E3>
ZZYU <char-0x30C3><char-0x30B8><char-0x30E5>
ZZYO <char-0x30C3><char-0x30B8><char-0x30E7>

BBYA <char-0x30C3><char-0x30D3><char-0x30E3>
BBYU <char-0x30C3><char-0x30D3><char-0x30E5>
BBYO <char-0x30C3><char-0x30D3><char-0x30E7>

PPYA <char-0x30C3><char-0x30D4><char-0x30E3>
PPYU <char-0x30C3><char-0x30D4><char-0x30E5>
PPYO <char-0x30C3><char-0x30D4><char-0x30E7>
