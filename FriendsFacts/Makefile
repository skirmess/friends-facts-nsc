
.PHONY: clean tag release

VERSION=12

clean:
	rm -f *~

tag: clean
	cvs tag FriendsFacts-$(VERSION)

release: clean
	( cd ..;							\
		rm -f FriendsFacts-$(VERSION).zip;			\
		find FriendsFacts					\
				-name CVS -prune -o			\
				-name .svn -prune -o			\
				-name Makefile -prune -o		\
				-name '.*.swp' -prune -o		\
				-print					\
		| zip -@ FriendsFacts-NSC-$(VERSION).zip;		\
	)	
