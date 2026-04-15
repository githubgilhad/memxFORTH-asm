#!/usr/bin/python -u
# vim: fileencoding=utf-8:nomodified:nowrap:textwidth=0:foldmethod=marker:foldcolumn=4:ruler:showcmd:lcs=tab\:|- list:tabstop=8:noexpandtab:nosmarttab:softtabstop=0:shiftwidth=0


import sys
from dataclasses import dataclass, field


@dataclass
class Node:
	start: int
	end: int
	name: str
	children: list = field(default_factory=list)

	def contains(self, other):
		return self.start <= other.start and self.end >= other.end


def parse_line(line):
	parts = line.split()
	start = int(parts[0], 16)
	end = int(parts[2], 16)
	name = parts[5]
	return Node(start, end, name)


def build_tree(nodes):
	nodes.sort(key=lambda n: (n.start, -n.end))

	root = Node(0, 0xFFFFFFFF, "ROOT")
	stack = [root]

	for node in nodes:
		while not stack[-1].contains(node):
			stack.pop()
		stack[-1].children.append(node)
		stack.append(node)

	return root


def fill_gaps(node):
	if not node.children:
		return

	# vezmi snapshot původních dětí
	children = sorted(node.children, key=lambda c: c.start)

	new_children = []
	current = node.start

	for child in children:
		if child.start > current:
			if child.start == 0x800200 :
				new_children.append(Node(current, child.start, "<=====  RAM START =====>"))
			else:
				new_children.append(Node(current, child.start, "(unknown)"))
		new_children.append(child)
		current = child.end

	if (current < node.end) and (node.end != 0xFFFFFFFF):
		new_children.append(Node(current, node.end, "(unknown)"))

	node.children = new_children

	# REKURZE jen do skutečných uzlů (ne gapů!)
	for child in node.children:
		fill_gaps(child)


def print_tree(node, indent=-1):
#	print(
#		"\t" * indent +
#		f"{node.start:08x}..{node.end:08x} {node.end-node.start:08x} "+
#		f"\t\t\t" +
#		f"{node.end-node.start:-8}	{node.name}"
#	)
	if indent >= 0:
		print(
			"\t" * indent +
			f"{node.end-node.start:-8}  {node.name}" +
			f"\t" +
			f"{node.start:08x}..{node.end:08x} {node.end-node.start:08x} "
		)
	for child in node.children:
		print_tree(child, indent + 1)


def read_input():
	if len(sys.argv) < 2 or sys.argv[1] == "-":
		return sys.stdin
	else:
		return open(sys.argv[1])


def main():
	f = read_input()

	nodes = [parse_line(line) for line in f if line.strip()]

	if f is not sys.stdin:
		f.close()

	tree = build_tree(nodes)
	fill_gaps(tree)
	print_tree(tree)


if __name__ == "__main__":
	main()


