require("math")

-- Create our core namespaces accessible from all scripts requiring this.
psi = {}
path = {}
psi.video = {}

function psi.video.set(video)
	psi.video = video
end

--- is this an absolute path?.
-- @param P A file path
function path.isabs(P)
	return string.sub(P,1,1) == '/'
end

-- !constant sep is the directory separator for this platform.
path.sep = package.config:sub(1, 1)

--- return the path resulting from combining the individual paths.
-- if the second path is absolute, we return that path.
-- @param p1 A file path
-- @param p2 A file path
-- @param ... more file paths
function path.join(p1,p2,...)
	assert((p1 and p2), "missing path component(s)")

	if select('#',...) > 0 then
		local p = path.join(p1,p2)
		local args = {...}
		for i = 1,#args do
			p = path.join(p,args[i])
		end
		return p
	end

	if path.isabs(p2) then return p2 end

	local endc = string.sub(p1,#p1,#p1)
	if endc ~= path.sep and endc ~= other_sep then
		p1 = p1..path.sep
	end

	return p1..p2
end

function path.exists(name)
	assert(name, "missing path")

	-- Try to open the file
	local f=io.open(name,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false
	end
end

psi.renderer = {}

psi.version = "Version 0.600"
psi.copyright = "Copyright (C) 2021 Sakari Lehtonen <sakari@psitriangle.net>"

-- Add constant values.
psi.math = {}
-- Golden ratio, or Phi.
psi.math.PHI = ((1 + 2.23606797749979) / 2)
psi.math.TWO_PI = math.pi*2.0
