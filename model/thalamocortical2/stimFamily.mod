TITLE 30-step current clamp

COMMENT
    Since this is an electrode current, positive values of i depolarize the
    cell and in the presence of the extracellular mechanism there will be a
    change in vext since i is not a transmembrane current but a current
    injected directly to the inside of the cell.

ENDCOMMENT

NEURON {
	POINT_PROCESS IClampFamily
	RANGE dur1, dur2, dur3, dur4, dur5, dur6, dur7, dur8, dur9, dur10
    RANGE dur11, dur12, dur13, dur14, dur15, dur16, dur17, dur18, dur19, dur20
    RANGE dur21, dur22, dur23, dur24, dur25, dur26, dur27, dur28, dur29, dur30
	RANGE amp1, amp2, amp3, amp4, amp5, amp6, amp7, amp8, amp9, amp10
    RANGE amp11, amp12, amp13, amp14, amp15, amp16, amp17, amp18, amp19, amp20
    RANGE amp21, amp22, amp23, amp24, amp25, amp26, amp27, amp28, amp29, amp30
    ELECTRODE_CURRENT i
}

UNITS {
	(nA) = (nanoamp)
}

PARAMETER {
	dur1  (ms)	<0,1e9>
    dur2  (ms)	<0,1e9>
    dur3  (ms)	<0,1e9>
    dur4  (ms)	<0,1e9>
    dur5  (ms)	<0,1e9>
    dur6  (ms)	<0,1e9>
    dur7  (ms)	<0,1e9>
    dur8  (ms)	<0,1e9>
    dur9  (ms)	<0,1e9>
    dur10 (ms)	<0,1e9>
    dur11 (ms)	<0,1e9>
    dur12 (ms)	<0,1e9>
    dur13 (ms)	<0,1e9>
    dur14 (ms)	<0,1e9>
    dur15 (ms)	<0,1e9>
    dur16 (ms)	<0,1e9>
    dur17 (ms)	<0,1e9>
    dur18 (ms)	<0,1e9>
    dur19 (ms)	<0,1e9>
    dur20 (ms)	<0,1e9>
    dur21 (ms)	<0,1e9>
    dur22 (ms)	<0,1e9>
    dur23 (ms)	<0,1e9>
    dur24 (ms)	<0,1e9>
    dur25 (ms)	<0,1e9>
    dur26 (ms)	<0,1e9>
    dur27 (ms)	<0,1e9>
    dur28 (ms)	<0,1e9>
    dur29 (ms)	<0,1e9>
    dur30 (ms)	<0,1e9>
	amp1  (nA)
    amp2  (nA)
    amp3  (nA)
    amp4  (nA)
    amp5  (nA)
    amp6  (nA)
    amp7  (nA)
    amp8  (nA)
    amp9  (nA)
    amp10 (nA)
    amp11 (nA)
    amp12 (nA)
    amp13 (nA)
    amp14 (nA)
    amp15 (nA)
    amp16 (nA)
    amp17 (nA)
    amp18 (nA)
    amp19 (nA)
    amp20 (nA)
    amp21 (nA)
    amp22 (nA)
    amp23 (nA)
    amp24 (nA)
    amp25 (nA)
    amp26 (nA)
    amp27 (nA)
    amp28 (nA)
    amp29 (nA)
    amp30 (nA)
}

ASSIGNED {
    i (nA)
}

INITIAL {
	i = 0
}

BREAKPOINT {
    if (dur1) {
        at_time(0)
        at_time(dur1)
    }
	if (dur2)  {at_time(dur1+dur2)}
    if (dur3)  {at_time(dur1+dur2+dur3)}
    if (dur4)  {at_time(dur1+dur2+dur3+dur4)}
    if (dur5)  {at_time(dur1+dur2+dur3+dur4+dur5)}
    if (dur6)  {at_time(dur1+dur2+dur3+dur4+dur5+dur6)}
    if (dur7)  {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7)}
    if (dur8)  {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8)}
    if (dur9)  {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9)}
    if (dur10) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10)}
    if (dur11) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11)}
    if (dur12) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12)}
    if (dur13) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13)}
    if (dur14) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14)}
    if (dur15) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15)}
    if (dur16) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16)}
    if (dur17) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17)}
    if (dur18) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18)}
    if (dur19) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19)}
    if (dur20) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20)}
    if (dur21) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21)}
    if (dur22) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22)}
    if (dur23) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23)}
    if (dur24) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24)}
    if (dur25) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25)}
    if (dur26) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26)}
    if (dur27) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27)}
    if (dur28) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27+dur28)}
    if (dur29) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27+dur28+dur29)}
    if (dur30) {at_time(dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27+dur28+dur29+dur30)}
	
    if (t <= dur1) {
		i = amp1
	} else if (t <= dur1+dur2) {
		i = amp2
	} else if (t <= dur1+dur2+dur3) {
        i = amp3
    } else if (t <= dur1+dur2+dur3+dur4) {
        i = amp4
    } else if (t <= dur1+dur2+dur3+dur4+dur5) {
        i = amp5
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6) {
        i = amp6
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7) {
        i = amp7
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8) {
        i = amp8
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9) {
        i = amp9
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10) {
        i = amp10
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11) {
        i = amp11
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12) {
        i = amp12
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13) {
        i = amp13
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14) {
        i = amp14
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15) {
        i = amp15
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16) {
        i = amp16
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17) {
        i = amp17
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18) {
        i = amp18
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19) {
        i = amp19
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20) {
        i = amp20
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21) {
        i = amp21
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22) {
        i = amp22
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23) {
        i = amp23
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24) {
        i = amp24
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25) {
        i = amp25
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26) {
        i = amp26
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27) {
        i = amp27
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27+dur28) {
        i = amp28
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27+dur28+dur29) {
        i = amp29
    } else if (t <= dur1+dur2+dur3+dur4+dur5+dur6+dur7+dur8+dur9+dur10+dur11+dur12+dur13+dur14+dur15+dur16+dur17+dur18+dur19+dur20+dur21+dur22+dur23+dur24+dur25+dur26+dur27+dur28+dur29+dur30) {
        i = amp30
    } else {
        i = 0
    }
}
