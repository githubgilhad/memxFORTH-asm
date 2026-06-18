

Pridelat DEV0.OE = 

.. code::

	
	Name     ATF1_GLUE;
	PartNo   0001;
	Date     2026-06-13;
	Revision 0.1;
	Designer ChatGPT;
	Device   g22v10;
	
	/************************************************************/
	/* INPUTS                                                   */
	/************************************************************/
	
	PIN = CA0;
	PIN = CA1;
	PIN = CA2;
	PIN = CA3;
	PIN = CA4;
	PIN = CA5;
	PIN = CA6;
	PIN = CA7;
	PIN = CA8;
	PIN = CA9;
	PIN = CA10;
	PIN = CA11;
	PIN = CA12;
	PIN = CA13;
	PIN = CA14;
	PIN = CA15;
	
	PIN = E;
	PIN = RW;
	PIN = RESET;
	PIN = HALT;
	
	/************************************************************/
	/* OUTPUTS                                                  */
	/************************************************************/
	
	PIN = MR0;
	PIN = MR1;
	PIN = MR2;
	PIN = MR3;
	
	PIN = DEV0;
	PIN = DEV1;
	PIN = DEV2;
	PIN = DEV3;
	PIN = DEV4;
	PIN = DEV5;
	PIN = DEV6;
	PIN = DEV7;
	
	PIN = READ_N;
	PIN = WRITE_N;
	
	/************************************************************/
	
	FIELD CA = [CA15..CA0];
	FIELD MR = [MR3..MR0];
	
	/************************************************************/
	/* ADDRESS DECODE                                           */
	/************************************************************/
	
	NATIVE_RAM_LO = !CA15;
	
	EMS1_WINDOW =
	      CA15
	    & !CA14
	    & !CA13
	    & !CA12;
	
	EMS2_WINDOW =
	      CA15
	    & !CA14
	    & !CA13
	    &  CA12;
	
	REG0 = (CA:$A000);
	REG1 = (CA:$A001);
	REG2 = (CA:$A002);
	REG3 = (CA:$A003);
	REG4 = (CA:$A004);
	REG5 = (CA:$A005);
	
	REG_MIRROR =
	      (CA >= $A006)
	    & (CA <= $A01F);
	
	DEVICE_AREA =
	      (CA >= $A020)
	    & (CA <= $A0FF);
	
	ROM_AREA =
	      (CA >= $A100);
	
	/************************************************************/
	/* MEMORY REGION BUS                                        */
	/************************************************************/
	
	MR = 0;
	
	IF NATIVE_RAM_LO THEN MR = 0;       /* 0000 */
	IF EMS1_WINDOW   THEN MR = 1;       /* 0001 */
	IF EMS2_WINDOW   THEN MR = 2;       /* 0010 */
	
	IF REG0 THEN MR = 8;                /* 1000 */
	IF REG1 THEN MR = 9;                /* 1001 */
	IF REG2 THEN MR = 10;               /* 1010 */
	IF REG3 THEN MR = 11;               /* 1011 */
	IF REG4 THEN MR = 12;               /* 1100 */
	IF REG5 THEN MR = 13;               /* 1101 */
	
	IF REG_MIRROR THEN MR = 15;         /* 1111 */
	
	IF DEVICE_AREA THEN MR = 4;         /* 0100 */
	
	IF ROM_AREA THEN MR = 3;            /* 0011 */
	
	/************************************************************/
	/* READ / WRITE                                             */
	/************************************************************/
	
	READ_N  = !(E & RW);
	WRITE_N = !(E & !RW);
	
	/************************************************************/
	/* DEVICE SELECTS                                           */
	/************************************************************/
	
	/* default inactive */
	
	DEV1 = 1;
	DEV2 = 1;
	DEV3 = 1;
	DEV4 = 1;
	DEV5 = 1;
	DEV6 = 1;
	DEV7 = 1;
	
	/************************************************************/
	/* DEV0 (System RAM)                                        */
	/************************************************************/
	
	/*
	 * EMS windows:
	 *   ATF1 releases DEV0
	 *   ATF2 drives DEV0
	 */
	
	DEV0 = !(NATIVE_RAM_LO # ROM_AREA);
	EMS_WINDOW = EMS1_WINDOW # EMS2_WINDOW;
	
	DEV0.OE = !EMS_WINDOW;
	
	/************************************************************/
	/* DEVICE BLOCK                                             */
	/************************************************************/
	
	DEV1 = !(
	       DEVICE_AREA
	    & !CA7
	    & !CA6
	    & !CA5
	);
	
	DEV2 = !(
	       DEVICE_AREA
	    & !CA7
	    & !CA6
	    &  CA5
	);
	
	DEV3 = !(
	       DEVICE_AREA
	    & !CA7
	    &  CA6
	    & !CA5
	);
	
	DEV4 = !(
	       DEVICE_AREA
	    & !CA7
	    &  CA6
	    &  CA5
	);
	
	DEV5 = !(
	       DEVICE_AREA
	    &  CA7
	    & !CA6
	    & !CA5
	);
	
	DEV6 = !(
	       DEVICE_AREA
	    &  CA7
	    & !CA6
	    &  CA5
	);
	
	DEV7 = !(
	       DEVICE_AREA
	    &  CA7
	    &  CA6
	    & !CA5
	);



