psi.texture = {}

-- List of global shaders used
-- Used to pass shaders to all the modules
psi.texture.sampleMode = {
	LINEAR       	= 0x000,
	LINEAR_MIPMAP  	= 0x001,
	NEAREST      	= 0x010,
	ANISOTROPIC  	= 0x011,
	FILTER_MASK   	= 0x111,
	REPEAT       	= 0x0001,
	CLAMP        	= 0x1000,
	CLAMP_BORDER  	= 0x1001,
	ADDRESS_MASK  	= 0x1111,
	COUNT        	= 13
}
