
/*
Spatial Reference Id's (SRID)
 - Identify a position on earth
 - Multipe SRID's - 4326 or 4269
 - 4326 is the most common

 Point - a single coordinate

 Linestring

 Uses methods and properties from a CLR library

https://www.youtube.com/watch?v=f0YJFp7BQyc

 Datatype::Method(point/line, SRID)

 https://www.google.com/maps/place/1651+2055+S,+Syracuse,+UT+84075/@41.0837828,-112.0578317,21z/data=!4m13!1m7!3m6!1s0x87531ca85c6ebd57:0x7838e73fbc61c6bf!2s1651+2055+S,+Syracuse,+UT+84075!3b1!8m2!3d41.0837543!4d-112.0577439!3m4!1s0x87531ca85c6ebd57:0x7838e73fbc61c6bf!8m2!3d41.0837543!4d-112.0577439

-112.057925 41.083816,
-112.057761 41.083889, 
-112.057373 41.083715,
-112.057373 41.083551,
-112.057857 41.083551

Latitudes range from 0 to 90. Longitudes range from 0 to 180

Points - longitude latitude
*/


/*Uses a clockwise winding which seems like it doesn't like*/
SELECT
	geography::STPolyFromText('POLYGON((-112.057925 41.083816, -112.057761 41.083889, -112.057373 41.083715, -112.057373 41.083551, -112.057857 41.083551, -112.057925 41.083816))', 4326)


/* We can see that it does look correct... */
SELECT
	geography::STLineFromText('LINESTRING(-112.057925 41.083816, -112.057761 41.083889, -112.057373 41.083715, -112.057373 41.083551, -112.057857 41.083551, -112.057925 41.083816)', 4326)


/* Winding the polygon counterclockwise*/
SELECT
	geography::STPolyFromText('POLYGON((-112.057857 41.083551, -112.057373 41.083551, -112.057373 41.083715, -112.057761 41.083889, -112.057925 41.083816, -112.057857 41.083551))', 4326)


/* Area & Perimeter

SRID 4137 for square feet

 */

DECLARE @Poly geography
SET @Poly = geography::STPolyFromText('POLYGON((-112.057857 41.083551, -112.057373 41.083551, -112.057373 41.083715, -112.057761 41.083889, -112.057925 41.083816, -112.057857 41.083551))', 4157)

SELECT @Poly.STArea()
SELECT @Poly.STLength()


/* From WideWorldImporters */

SELECT
	C.CityID,
	C.CityName,
	C.Location,
	C.Location.Long,
	C.Location.Lat

FROM
	Application.Cities C
	INNER JOIN Application.StateProvinces SP ON C.StateProvinceID = SP.StateProvinceID
		AND SP.StateProvinceCode = 'UT'



