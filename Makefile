build:
	odin build src -out:raytracer
	./raytracer > image.ppm
	feh image.ppm

clean: 
	rm image.ppm
	rm raytracer
