// PERSISTENT ROTATION WORKAROUND
// THERE IS A BUG ON kOS THAT BREAKS SAS MODES WHEN SWITCHING ACTIVE VESSEL
// YOU CAN ADD THIS TO A CORE ON THE SAME STAGE AS YOUR PAYLOAD

clearscreen.
set core:tag to "P-ROT".

until false { wait 0.
	if (core:messages:empty) { print "CORE EMPTY" at (0, 1). }
	else {
		local received is core:messages:pop.
		if (received:content[0] = 0) { core:messages:clear(). reboot. }
		local payloadType is received:content[0].
		set navmode to received:content[1]. sas on. wait 0.5.
		if (payloadType = 2 or payloadType = 3) { set sasmode to received:content[2]. }
		else { set sasmode to received:content[2]. }  wait 2.5.
		core:messages:clear().
	}
}