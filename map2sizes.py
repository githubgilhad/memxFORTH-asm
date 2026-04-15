#!/usr/bin/python -u
# vim: fileencoding=utf-8:nomodified:nowrap:textwidth=0:foldmethod=marker:foldcolumn=4:ruler:showcmd:lcs=tab\:|- list:tabstop=8:noexpandtab:nosmarttab:softtabstop=0:shiftwidth=0
import re
import sys

if len(sys.argv) < 2:
	print("Usage: python map_parser.py <file.map>")
	sys.exit(1)

filename = sys.argv[1]

# řádek s adresou a velikostí
addr_pattern = re.compile(r'^\s*0x([0-9a-fA-F]+)\s+0x([0-9a-fA-F]+)')

# řádek typu ".text.xxx"
section_pattern = re.compile(r'^\s*(\.\S+)\s*$')

# řádek typu ".text.xxx 0xADDR 0xSIZE ..."
inline_pattern = re.compile(r'^\s*(\.\S+)\s+0x([0-9a-fA-F]+)\s+0x([0-9a-fA-F]+)')


class Node:
	def __init__(self, name, full_name):
		self.name = name
		self.full_name = full_name
		self.children = {}
		self.ranges = []

	def add_range(self, addr, size):
		self.ranges.append((addr, addr + size))

	def get_child(self, name, full_name):
		if name not in self.children:
			self.children[name] = Node(name, full_name)
		return self.children[name]

	def compute(self):
		starts = []
		ends = []

		for s, e in self.ranges:
			starts.append(s)
			ends.append(e)

		for child in self.children.values():
			cs, ce = child.compute()
			if cs is not None:
				starts.append(cs)
				ends.append(ce)

		if not starts:
			self.start = None
			self.end = None
			return None, None

		self.start = min(starts)
		self.end = max(ends)
		return self.start, self.end

	def print(self, indent=0):
		if self.start is not None:
			size = self.end - self.start
#				"  " * indent +
			print( 
				f"{self.start:08x} .. {self.end:08x} " +
				f"{size:06x} " + 
				"\t" * indent +
				f"{size:6d} {self.full_name}"
			)

		children = sorted(
			self.children.values(),
			key=lambda x: (x.start if x.start is not None else 0)
		)

		for child in children:
			child.print(indent + 1)


root = Node("root", "")

pending_section = None

intro = True
outro = False
intro_pattern = re.compile(r'^Linker script and memory map')
outro_pattern = re.compile(r'^.fuse')

with open(filename) as f:
	for line in f:
		if intro:
			m = intro_pattern.match(line)
			if m:
				intro = False
			continue
		m = outro_pattern.match(line)
		if m:
			outro = True
		if outro:
			continue

		# 1) inline varianta (.text.xxx 0x.. 0x..)
		m = inline_pattern.match(line)
		if m:
			name = m.group(1)
			addr = int(m.group(2), 16)
			size = int(m.group(3), 16)

			if size > 0:
				parts = name.split('.')[1:]
				current = root
				full = ""
				for part in parts:
					full += "." + part
					current = current.get_child(part, full)
				current.add_range(addr, size)

			pending_section = None
			continue

		# 2) samotný název sekce
		m = section_pattern.match(line)
		if m:
			pending_section = m.group(1)
			continue

		# 3) řádek s adresou (patří k pending sekci)
		if pending_section:
			m = addr_pattern.match(line)
			if m:
				addr = int(m.group(1), 16)
				size = int(m.group(2), 16)

				if size > 0:
					parts = pending_section.split('.')[1:]
					current = root
					full = ""
					for part in parts:
						full += "." + part
						current = current.get_child(part, full)
					current.add_range(addr, size)

				pending_section = None
			continue


root.compute()
root.print()

