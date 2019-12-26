#! /bin/bash


import extargsparse
import logging
import sys
import re

def set_logging(args):
	loglvl= logging.ERROR
	if args.verbose >= 3:
		loglvl = logging.DEBUG
	elif args.verbose >= 2:
		loglvl = logging.INFO
	if logging.root is not None and len(logging.root.handlers) > 0:
		logging.root.handlers = []
	logging.basicConfig(level=loglvl,format='%(asctime)s:%(filename)s:%(funcName)s:%(lineno)d\t%(message)s')
	return


def read_file(infile=None):
	fin = sys.stdin
	if infile is not None:
		fin = open(infile,'r+b')
	rets = ''
	for l in fin:
		s = l
		if 'b' in fin.mode:
			if sys.version[0] == '3':
				s = l.decode('utf-8')
		rets += s

	if fin != sys.stdin:
		fin.close()
	fin = None
	return rets

def write_file(s,outfile=None):
	fout = sys.stdout
	if outfile is not None:
		fout = open(outfile, 'w+b')
	outs = s
	if 'b' in fout.mode:
		outs = s.encode('utf-8')
	fout.write(outs)
	if fout != sys.stdout:
		fout.close()
	fout = None
	return 

def clean_handler(args,parser):
	set_logging(args)
	s = read_file(args.input)
	sarr = re.split('\n', s)
	outs = ''
	resp = '^[A-Za-z]:[^>]+>'
	tabres = '^\t'
	lastsp = '[ \t]+$'
	clexpr = re.compile('^cl.exe ',re.I)
	libexpr = re.compile('^lib.exe ',re.I)
	linkexpr = re.compile('^link.exe ',re.I)
	rcexpr = re.compile('^rc.exe ',re.I)
	for l in sarr:
		l = l.rstrip('\r\n')
		if len(l) == 0:
			continue
		l = re.sub(resp,'',l)
		l = re.sub(tabres,'',l)
		l = re.sub(lastsp,'',l)
		if clexpr.match(l) or libexpr.match(l) or linkexpr.match(l) or rcexpr.match(l):
			outs += l
			outs += '\n'
	write_file(outs,args.input)
	sys.exit(0)
	return


def main():
	commandline='''
	{
		"verbose|v" : "+",
		"input|i" : null,
		"clean<clean_handler>" : {
			"$" : 0
		}
	}
	'''
	parser = extargsparse.ExtArgsParse()
	parser.load_command_line_string(commandline)
	parser.parse_command_line(None,parser)
	raise Exception('can not return')
	return

if __name__ == '__main__':
	main()