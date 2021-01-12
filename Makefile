LUAS = $(wildcard *.lua)
IMGS = $(wildcard www/*.gif www/icons/*/*.png)

all: kymera.c4z

kymera.c4z: driver.xml $(LUAS) $(IMGS) www/doc.rtf
	zip $@ $^

www/doc.rtf: README.md
	-@mkdir -p www
	pandoc -s -f markdown -t rtf -o $@ $^

clean:
	rm kymera.c4z www/doc.rtf
	rmdir www
