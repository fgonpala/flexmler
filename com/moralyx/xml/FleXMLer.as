package com.moralyx.xml
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	public class FleXMLer
	{
		/*
		 * Utility methods
		 */
 
		private function valOrDefault(val:Object, def:*):*
		{
			return val ? val : def;
		}
		
		private static function createXMLNode(name:String):XML
		{
			var res:XML = <dummy/>;			
			res.setName(name);
			return res;
		}
		
		private static function isPrimitiveType(type:Class):Boolean
		{
			return (type == Number || type == int || type == String || type == Date || type == Boolean);			
		}

		private function convertStringToType(str:String, type:Class):*
		{
			if (!type)
				throw new ArgumentError("type cannot be null");
				
			switch (type)
			{
				case Number: 	return new Number(str);
				case int: 		return new int(str);
				case String: 	return str;
				case Date: 		return new Date(Date.parse(str));
				case Boolean:	return str == "true" ? true : false;					
				default: 		throw new ArgumentError("Unsupported type: " + type);
			}
			return null;
		}

		// reads metadata from a type description "FleXMLer" annotations, for both class and variables and read/write accessors
		// returns a hash of { propname : { argname : value } }, where propnam = "/" for class annotations
		
		private function getMetadata(typeDesc:XML) : Object
		{
			var metadata:Object = { };
			
			var parent:XML = typeDesc.factory.length() > 0 ? typeDesc.factory[0] : typeDesc;
			
			var classMeta:Object = metadata["/"] = { };
			for each (var metaDef:XML in parent.metadata.(@name == "FleXMLer"))
			{
				readMetadataArgs(metaDef, classMeta);
			}
			
			var propDefs:XMLList = parent.variable;
			propDefs += parent.accessor.(@access == "readwrite");
						
			for each (var propDef:XML in propDefs) 
			{
				var propMeta:Object = metadata[propDef.@name] = {}
				for each (var xmd:XML in propDef.metadata.(@name == "FleXMLer"))
				{
					readMetadataArgs(xmd, propMeta);
				}				
			}
			
			return metadata;
		}

		// reads metadata argument settings from the given type description entry
		// update the given hash by adding { argname : value } entries 

		private function readMetadataArgs(xmd:XML, settings:Object):void
		{			
			for each (var xarg:XML in xmd.arg)
			{
				settings[xarg.@key] = xarg.@value;				
			}
		}
		
		/*
		 * Serialize
		 */
		
		public function serialize(o:*):XML
		{
			return _serialize(o, null);
		}
		
		private function _serialize(o:*, alias:String = null):XML
		{			
			if (o == null)
				return <null/>;
				
			var typeDesc:XML = describeType(o); 
			
			var typeMeta:Object = getMetadata(typeDesc);
			
			var rootMeta:Object = valOrDefault(typeMeta["/"], { } );
			
			// node name is the type name by default
			// if alias specified (for array members) use it as node name 
			// otherwise, if metadata was specified for type and includes alias, use it
						
			var rootNodeName:String = typeDesc.@name;			
			if (alias)
				rootNodeName = alias;
			else if (rootMeta["alias"])
				rootNodeName = rootMeta["alias"];
			
			// create XML node
			
			var res:XML = createXMLNode(rootNodeName);
			
			// primitive types - simply set the node text to the value toString and return
			
			if (o is Number || o is int || o is String || o is Date || o is Boolean)
			{
				res.appendChild(o.toString());
				return res;
			}

			// gather all properties = variables + read/write accessors
			
			var propDefs:XMLList = typeDesc.variable;
			propDefs += typeDesc.accessor.(@access == "readwrite");
			
			for each (var propDef:XML in propDefs) 
			{
				var name:String = propDef.@name;
				var type:String = propDef.@type;
				var val:* = o[name];
				
				var propMeta:Object = valOrDefault(typeMeta[name], {});
				
				if (propMeta["skip"] == "serialize" || propMeta["skip"] == "always")
				{
					continue;
				}
				
				var elmName:String = valOrDefault(propMeta["alias"], name);
								
				var xprop:XML = createXMLNode(elmName);
				
				switch (type)
				{
					case "int":
					case "Number":
					case "String":
					case "Date":
					case "Boolean":						
						xprop.appendChild(val);
						break;
						
					case "Array":											
						if (val)
						{
							var memberAlias:String = valOrDefault(propMeta["memberAlias"], null);
							for each (var member:* in val)
							{
								xprop.appendChild(_serialize(member, memberAlias));
							}
						}
						break;
						
					case "Object":
						if (val)
						{	
							// default - create entries in format:  
							//   <entry><key><keyType>key_string</keyType></key><value><valueType>value_string</valueType></value></entry>
							
							// if entryAlias/keyAlias/valueAlias are given, use instead of entry/key/value

							var entryAlias:String = valOrDefault(propMeta["entryAlias"], "entry");
							var keyAlias:String = valOrDefault(propMeta["keyAlias"], "key");
							var valueAlias:String = valOrDefault(propMeta["valueAlias"], "value");
							
							// if keyType/valueType are given, no need to use keyType/valueType
							
							var keyType:Class = propMeta["keyType"] ? getDefinitionByName(propMeta["keyType"]) as Class : null;
							var valueType:Class = propMeta["valueType"] ? getDefinitionByName(propMeta["valueType"]) as Class : null;
							
							// if keyAsElementName and keyType == "String", entries will use format: <key_string>value_string</key_string>
							
							var keyAsElementName:Boolean = propMeta["keyAsElementName"] == "true";
							
							for (var key:* in val)
							{
									var xentry:XML;
									var xval:XML;
									
									if (keyAsElementName && keyType == String)
									{
										// element element name is key value, value is written as text inside it
										
										xentry = createXMLNode(key);
										xval = xentry;
									}
									else
									{
										// element element name is 'entry' or given entryAlias
										
										xentry = createXMLNode(entryAlias);
									
										// create key element inside it, named 'key' or given entryAlias
										
										var xkey:XML = createXMLNode(keyAlias);
									
										// if keyType is specified and is primitive, no need to add a keyType element
										
										if (isPrimitiveType(keyType))
											xkey.appendChild(key);
										else
											xkey.appendChild(serialize(key));										
											
										xentry.appendChild(xkey);
										
										// create value element, named 'value' or given valueAlias
										
										xval = createXMLNode(valueAlias);									
									}
									
									// if valueType is specified and is primitive, no need to add a valueType element
										
									if (isPrimitiveType(valueType))
										xval.appendChild(val[key]);
									else
										xval.appendChild(serialize(val[key]));
									
									// if value is an independent element, place it under entry element
										
									if (xval != xentry)
										xentry.appendChild(xval);
									
									// add to property element
										
									xprop.appendChild(xentry);
							}
							
						}
						break;
						
					default:
						// a class type, do complex serialization
						if (val)
							xprop = _serialize(val, propMeta["alias"]);
						else
							xprop = null;
				}
				
				if (xprop)
					res.appendChild(xprop);
            }
			
			return res;			
		}
		
		/*
		 * Deserialize
		 */
		
		public function deserialize(xml:XML, type:Class = null):Object
		{
			return _deserialize(xml, type, null);
		}
		
		private function _deserialize(xml:XML, type:Class = null, elmMetadata:Object = null):Object
		{
			if (!xml || xml.name() == "null")
				return null;

			if (type == null)			
				type = getDefinitionByName(xml.name()) as Class;
			
			if (type == null)
				throw new Error("Couldn't resolve class " + xml.name());
				
			elmMetadata = valOrDefault(elmMetadata, { } );
			
			if ( elmMetadata["skip"] == "deserialize" || elmMetadata["skip"] == "always" )
			{
				if (elmMetadata["default"])
					return convertStringToType(elmMetadata["default"], type);
				else
					return null;
			}
			
			if (isPrimitiveType(type))
			{
				return convertStringToType(xml.text(), type);
			}
			else if (type == Array)
			{
				var arr:Array = [];
				
				for each (var xchild:XML in xml.children())
				{
					var memberType:Class = elmMetadata["memberType"] ? getDefinitionByName(elmMetadata["memberType"]) as Class : null;
					
					var child:* = _deserialize(xchild, memberType);
					arr.push(child);
				}
				return arr;
			}
			else if (type == Object)
			{
				var obj:Object = { };
				
				var entryAlias:String = valOrDefault(elmMetadata["entryAlias"], "entry");
				var keyAlias:String = valOrDefault(elmMetadata["keyAlias"], "key");
				var valueAlias:String = valOrDefault(elmMetadata["valueAlias"], "value");
				
				var keyType:Class = elmMetadata["keyType"] ? getDefinitionByName(elmMetadata["keyType"]) as Class : null;
				var valueType:Class = elmMetadata["valueType"] ? getDefinitionByName(elmMetadata["valueType"]) as Class : null;
				
				var keyAsElementName:Boolean = elmMetadata["keyAsElementName"] == "true" && keyType == String;
				
				// if we're using the key values as element names, the entries are all the direct children of the hash, 
				// otherwise they are only the children whose name is the entry alias
				
				var xentries:XMLList = (keyAsElementName ? xml.children() : xml[entryAlias]);
				
				for each (var xentry:XML in xentries)
				{
					var key:*;
					var xval:XML;
					
					if (keyAsElementName)
					{
						// the key is the entry XML element name, the value is its inner text
						key = xentry.name();						
						xval = xentry.children()[0];						
					}
					else
					{
						// the key is in an XML element whose name is the key alias						
						var xkey:XML = xentry[keyAlias][0];						
						
						// the value is in an XML element whose name is the value alias
						key = isPrimitiveType(keyType) ? convertStringToType(xkey.text(), keyType) : deserialize(xkey.children()[0], keyType);						
						xval = xentry[valueAlias][0];
					}
					
					var val:* = isPrimitiveType(valueType) ? convertStringToType(xval, valueType) : deserialize(xval.children()[0], valueType);
					obj[key] = val;
				}				
				
				return obj;
			}

			var typeDesc:XML = describeType(type); 						
			var typeMeta:Object = getMetadata(typeDesc);					
			var instance:* = new type();
			
			var propDefs:XMLList = typeDesc.factory.variable;
			propDefs += typeDesc.factory.accessor.(@access == "readwrite");
			
			for each (var propDef:XML in propDefs) 
			{				
				var vtype:String = propDef.@type;
				var propType:Class = flash.utils.getDefinitionByName(vtype) as Class;
				
				var name:String = propDef.@name;
				
				var propMeta:Object = valOrDefault(typeMeta[name], { } );								
				
				var elmName:String = valOrDefault(propMeta["alias"], name);				
				
				var xprop:XMLList = xml.child(elmName);
				
				var skip:Boolean = ( propMeta["skip"] == "deserialize" || propMeta["skip"] == "always" );
				
				if (xprop.length() > 0 && !skip)
				{
					instance[name] = _deserialize(xprop[0], propType, propMeta);
				}
				else 
				{
					var defaultVal:* = propMeta["default"];
					if (defaultVal)
					{
						instance[name] = convertStringToType(defaultVal, propType);
					}					
				}
            }
						
			return instance;			
		}
		
		
		
	}
}