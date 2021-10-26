
LIBRARIES = -lcurl -ljansson

VALGND := valgrind \
           --tool=memcheck \
           --leak-check=full \
           --show-leak-kinds=all \
           --show-reachable=yes 
           --num-callers=20 \
           --track-origins=yes \
           --track-fds=yes -v


miami: miami.c scrapeutils.c strutils.h
	$(CC) -o miami scrapeutils.c miami.c $(LIBRARIES)


format: FORCE
	clang-format *.c -i

test:
	$(VALGND) ./miami -a '8850 sw 170 st'

FORCE:

