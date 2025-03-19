// did it simmiliar like fad-guru here: https://www.shadertoy.com/view/sdVSRc
// (but not fully works yet;)

int iFrame = 0;
int seed;

float rand() {
	int n = (seed++ << 13) ^ seed;
	return float((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 2147483647.0;
}

#define INIT_SEED() seed = int(uTime * vTexCoord.x + vTexCoord.y * texRes.x); seed = int(rand() * 2147483647.0) + iFrame;

const int AIR  = 0;
const int SAND = 1;
const int WALL = 2;

struct Cell {
	int   type;
	bool  passed;
	float value;
};

Cell getCellAt( int textureID, vec2 texCoord ) {
	if (texCoord.x < 0.0 || texCoord.x >= 1.0 || texCoord.y < 0.0 || texCoord.y >= 1.0) return Cell(WALL, false, 0.0);
	vec4 col = getTextureColor( textureID, texCoord );
	return Cell(
		int(col.r*255.0),
		// bool(col.g),
		(col.g > 0.0) ? true : false,
		col.b
	);
}

vec4 cellToCol(Cell cell) {
	return vec4(
		float(cell.type)/255.0,
		// float(cell.passed),
		(cell.passed) ? 1.0 : 0.0,
		cell.value,
		1.0
	);
}

// ------------------------------------------------------------------------------------------
// ----------------------------------- PASS 1 -----------------------------------------------
// ------------------------------------------------------------------------------------------
vec4 pass1( int textureID )
{
	vec2 texRes = getTextureResolution(textureID);
	
	INIT_SEED();
	
	Cell self = getCellAt(textureID, vTexCoord);

	switch (self.type)
	{
		case SAND:
		{	
			Cell below = getCellAt(textureID, vTexCoord + vec2(0.0, 1.0) / texRes);
			if (below.type == AIR) {
				return cellToCol( Cell(AIR, true, 0.0) );
				// return cellToCol( Cell(AIR, false, 0.0) );
			}
		} break;
		
		case AIR:
		{	
			Cell above = getCellAt(textureID, vTexCoord + vec2(0.0, -1.0) / texRes);
			if (above.type == SAND) {
				above.passed = true;
				return cellToCol(above);
			}
		} break;
	}
	
	return cellToCol( Cell(self.type, false, self.value) );
}

// ------------------------------------------------------------------------------------------
// ----------------------------------- PASS 2 -----------------------------------------------
// ------------------------------------------------------------------------------------------
vec4 pass2( int textureID )
{
	// passthrought for testing:
	// return getTextureColor( textureID, vTexCoord );

	vec2 texRes = getTextureResolution(textureID);
	
	INIT_SEED();

	float xOffset = (rand() >= 0.5) ? 1.0 : -1.0;
	
	Cell self = getCellAt(textureID, vTexCoord);

	if (self.passed) {
		return cellToCol(self);
	}

	switch (self.type)
	{
		case SAND:
		{
			Cell below = getCellAt(textureID, vTexCoord + vec2(xOffset, 1.0) / texRes );

			if (!below.passed && below.type == AIR)
			{
				return cellToCol(Cell(AIR, true, 0.0));
			}
		}
		break;
		
		case AIR:
		{
			Cell above = getCellAt(textureID, vTexCoord + vec2(-xOffset, -1.0) / texRes );

			if (!above.passed && above.type == SAND)
			{
				above.passed = true;
				return cellToCol(above);
			}
		}
		break;
	}

	return cellToCol(self);
}

// ------------------------------------------------------------------------------------------
// ----------------------------------- PASS 3 -----------------------------------------------
// ------------------------------------------------------------------------------------------

// ... T O D O


// ------------------------------------------------------------------------------------------
// ----------------------- VIEW the CELLSTATE into its colors -------------------------------
// ------------------------------------------------------------------------------------------
vec4 view( int textureID )
{
	// passthrought for testing:
	// return getTextureColor( textureID, vTexCoord );

	Cell self = getCellAt(textureID, vTexCoord);

	switch (self.type)
	{
		case SAND:
		{
			return vec4(0.7, 0.6, 0.3, 1.0);
		}
		break;
		
		case AIR:
		{
			return vec4(0.0, 0.0, 0.0, 1.0);
		}
		break;
	}

	// WALL:
	return vec4(0.0, 0.0, 1.0, 1.0);
}
