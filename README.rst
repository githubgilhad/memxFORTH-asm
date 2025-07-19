.. vim: set ft=rst noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak showbreak=»\

.. |Ohm| raw:: html

	Ω

.. |kOhm| raw:: html

	kΩ


.. image:: MemxFORTHChipandColorfulStack.png
	:width: 250
	:target: MemxFORTHChipandColorfulStack.png

memxFORTH-asm
=============

This project builds memxFORTH directly from assembler and try to be memory-effective

* All pointers should be 3-bytes/24-bits long, also CELL size is 3-bytes, so there is no size mismatch between address and value
	* Extra-byte (bits 16..23) is 0x80 for RAM, 00..04 for FLASH (and maybe something else for paged RAM and Shared Ram)
	* all memory acceess should be via system calls: THIS and THAT
* reserved/assigned registers are this, every primitive is requered to protect and update them responsibly:
	* X - IP
	* Y - STACK
	* Z - RETURN stack


License
-------
GPL 2 or GPL 3 - choose the one that suits your needs.

Author
------
Gilhad - 2025

