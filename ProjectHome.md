# FleXMLer #

## Intro ##
FleXMLer (pronounced _'Flex-em-el-er'_) is an XML serialization / deserialization utility for Adobe Flex.<br>
<br>
By default FleXMLer uses reflection for out-of-the-box serialization.<br>
You can tweek the default serialization by using annotations. For example, you can indicate that a certain field should not be serialized, should be serialized using a specific element name, or should be serialized as an XML attribute.<br>
You can also specify serialization information programmatically at runtime instead of using reflection and annotations.<br>
<br>
FleXMLer is currently offered as source code only, since it's just a single file with under 500 lines of code.<br>
<br>
<h2>Usage</h2>
<pre><code>// serialize object to XML
var xml:XML = new FleXMLer().serialize(obj);

// deserialize XML to Object
var obj:MyType = new FleXMLer().deserialize(xmlobject[, MyType]);
</code></pre>

<b>Note:</b> If you use need to use the <code>[FleXMLer]</code> annotation, be sure to add the following compilation switch:<br>
<pre><code>-keep-as3-metadata+=FleXMLer
</code></pre>



<h2>Basic Serialization</h2>
Basic serialization supports all primitive types, and has special treatment for arrays and generic object hash tables.<br>
<br>
The following code:<br>
<pre><code>public class Basic
{
	public var name:String = "str";
	public var num:Number = 123.456;
	public var bool:Boolean = true;
	public var date:Date = new Date("Sat Feb 3 04:05:06 GMT-0500 2001");
	public var arr:Array = [123, "qwe", null, false];
	public var hash:Object = { 123 : true, "qwe" : new Date("Sat Feb 3 04:05:06 GMT-0500 2001") };

	private var _acc:Number;
		
	public function set acc(val:Number):void { _acc = val;  }
	public function get acc():Number { return _acc; }
}
</code></pre>
<pre><code>var b:Basic = new Basic();
b.acc = 987.65;
trace((new FleXMLer().serialize(b)).toXMLString());
</code></pre>

Produces:<br>
<br>
<pre><code>&lt;Basic&gt;
  &lt;name&gt;str&lt;/name&gt;
  &lt;num&gt;123.456&lt;/num&gt;
  &lt;date&gt;Sat Feb 3 11:05:06 GMT+0200 2001&lt;/date&gt;
  &lt;bool&gt;true&lt;/bool&gt;
  &lt;acc&gt;123.345&lt;/acc&gt;
  &lt;arr&gt;
    &lt;String&gt;123&lt;/String&gt;
    &lt;String&gt;qwe&lt;/String&gt;
    &lt;null/&gt;
    &lt;Boolean&gt;false&lt;/Boolean&gt;
  &lt;/arr&gt;
  &lt;hash&gt;
    &lt;entry&gt;
      &lt;key&gt;
        &lt;String&gt;qwe&lt;/String&gt;
      &lt;/key&gt;
      &lt;val&gt;
        &lt;Date&gt;Sat Feb 3 11:05:06 GMT+0200 2001&lt;/Date&gt;
      &lt;/val&gt;
    &lt;/entry&gt;
    &lt;entry&gt;
      &lt;key&gt;
        &lt;int&gt;123&lt;/int&gt;
      &lt;/key&gt;
      &lt;val&gt;
        &lt;Boolean&gt;true&lt;/Boolean&gt;
      &lt;/val&gt;
    &lt;/entry&gt;
  &lt;/hash&gt;
&lt;/Basic&gt;
</code></pre>

<h2>Nested Objects</h2>

Nested objects are handled by default as well.<br>
The following code:<br>
<pre><code>public class Nestee
{
	public var num:Number = 1.23;
}
</code></pre>
<pre><code>public class Nester
{
	public var str:String = "asd";
	public var n:Nestee = new Nestee();
}
</code></pre>
Produces:<br>
<pre><code>&lt;Nester&gt;
  &lt;str&gt;asd&lt;/str&gt;
  &lt;Nestee&gt;
    &lt;num&gt;1.23&lt;/num&gt;
  &lt;/Nestee&gt;
&lt;/Nester&gt;
</code></pre>

<h2>Serializing as attribute</h2>
Default serialization creates XML elements. <br>
Use the <code>[FleXMLer]</code> annotation with the <code>attribute</code> option to specify value should be serialized as an attribute.<br>
The default attribute name is the variable name.<br>
You can supply a string to be used as an attribute name.<br>
<pre><code>public class Attributes
{
	[FleXMLer(attribute)]
	public var att1:String = "val1";
	[FleXMLer(attribute=xxx)]
	public var att2:String = "val2";
}
</code></pre>

Produces:<br>
<br>
<pre><code>&lt;Attributes att1="val1" xxx="val2"/&gt;
</code></pre>

<h2>Aliasing</h2>
Default serialization uses the class or variable name for the XML element name. <br>
Use the <code>[FleXMLer]</code> annotation with the <code>alias</code> option to specify an alternative element name.<br>
<pre><code>[FleXMLer(alias="type_alias")]
public class Aliasing
{
	[FleXMLer(alias="var_alias")]
	public var name:String = "str";
}
</code></pre>

Produces:<br>
<br>
<pre><code>&lt;type_alias&gt;
  &lt;var_alias&gt;str&lt;/var_alias&gt;
&lt;/type_alias&gt;
</code></pre>

<b>Note:</b> XML element name is used in deserialization as the type of the object to create. <br>
If you modify the class element name, you must explicitly specify the type in the call to the <code>deserialize</code> method.<br>
<br>
<h2>Aliasing array members</h2>

Default serialization of array members uses the member class name for the XML element name.<br>
Use the <code>[FleXMLer]</code> annotation with the <code>memberAlias</code> option to specify an alternative element name.<br>
Since XML element name is used in deserialization as the type of the object to create, you must also specify the member type in the annotation using the <code>memberType</code> option.<br>
Naturally, this requires all array members to be of the same type.<br>
<pre><code>public class ArrayAliasing
{		
	[FleXMLer(memberAlias="num",memberType="Number")]
	public var arr:Array = [ 1.23, 2.34, null, 3.45 ];
}
</code></pre>
Produces:<br>
<pre><code>&lt;ArrayAliasing&gt;
  &lt;arr&gt;
    &lt;num&gt;1.23&lt;/num&gt;
    &lt;num&gt;2.34&lt;/num&gt;
    &lt;null/&gt;
    &lt;num&gt;3.45&lt;/num&gt;
  &lt;/arr&gt;
&lt;/ArrayAliasing&gt;

</code></pre>

<h2>Objects (Hash Tables)</h2>

Serialization of object hash members uses the following format by default:<br>
<pre><code>&lt;entry&gt;
  &lt;key&gt;
    &lt;key1Type&gt;key1&lt;/key1Type&gt;
  &lt;/key&gt;
  &lt;value&gt;
    &lt;value1Type&gt;value1&lt;/value1Type&gt;
  &lt;/value&gt;
&lt;/entry&gt;
&lt;entry&gt;
  &lt;key&gt;
    &lt;key2Type&gt;key2&lt;/key2Type&gt;
  &lt;/key&gt;
  &lt;value&gt;
    &lt;value2Type&gt;value2&lt;/value2Type&gt;
  &lt;/value&gt;
&lt;/entry&gt;
</code></pre>

You can change the names of any of the entry, key, or value XML element name using the <code>[FleXMLer]</code> annotation with the <code>entryAlias</code>, <code>keyAlias</code>, and <code>valueAlias</code> correspondingly.<br>
<pre><code>public class Hash
{
	[FleXMLer(entryAlias="e",keyAlias="k",valueAlias="v")]
	public var h:Object = { 1 : "qwe", 3 : "wer" };
}
</code></pre>
Produces:<br>
<pre><code>&lt;Hash&gt;
  &lt;h&gt;
    &lt;e&gt;
      &lt;k&gt;
        &lt;int&gt;1&lt;/int&gt;
      &lt;/k&gt;
      &lt;v&gt;
        &lt;String&gt;qwe&lt;/String&gt;
      &lt;/v&gt;
    &lt;/e&gt;
    &lt;e&gt;
      &lt;k&gt;
        &lt;int&gt;3&lt;/int&gt;
      &lt;/k&gt;
      &lt;v&gt;
        &lt;String&gt;wer&lt;/String&gt;
      &lt;/v&gt;
    &lt;/e&gt;
  &lt;/h&gt;
&lt;/Hash&gt;
</code></pre>

Specifying a fixed type name for keys and/or values using the <code>keyType</code> and <code>valueType</code> options will generate XML without the type names.<br>
<br>
<pre><code>public class Hash
{
	[FleXMLer(keyType="Number",valueType="Boolean")]
	public var h2:Object = { 1.23 : true, 3.45 : false };
}
</code></pre>
Produces:<br>
<pre><code>&lt;hash&gt;
  &lt;h2&gt;
    &lt;entry&gt;
      &lt;key&gt;3.45&lt;/key&gt;
      &lt;value&gt;false&lt;/value&gt;
    &lt;/entry&gt;
    &lt;entry&gt;
      &lt;key&gt;1.23&lt;/key&gt;
      &lt;value&gt;true&lt;/value&gt;
    &lt;/entry&gt;
  &lt;/h2&gt;
&lt;/hash&gt;
</code></pre>

An ever more concise XML can be generated for hashes using the <code>keyAsElementName</code> option (requires <code>keyType="String"</code>).<br>
<pre><code>public class Hash
{
	[FleXMLer(keyType="String",valueType="Number",keyAsElementName="true")]
	public var h3:Object = { "qweqwe" : 1.234, "zxczxczc" : 9.876 };
}
</code></pre>
Produces:<br>
<pre><code>&lt;Hash&gt;
  &lt;h3&gt;
    &lt;zxczxczc&gt;9.876&lt;/zxczxczc&gt;
    &lt;qweqwe&gt;1.234&lt;/qweqwe&gt;
  &lt;/h3&gt;
&lt;/Hash&gt;
</code></pre>



<h2>Specifying default values</h2>

Use the <code>[FleXMLer]</code> annotation with the <code>default</code> option to specify a default value to use in deserialization if a variable was not specified.<br>
This option can only apply to 'primitive' types (int, Number, Boolean, String, Date).<br>

The following code:<br>
<pre><code>public class Default
{
	[FleXMLer(default = "123")]	
	public var num:int;
}
</code></pre>

<pre><code>  var d:Default = new FleXMLer().deserialize(&lt;Default/&gt;);
  trace(d.num.toString());
</code></pre>

Produces:<br>
<pre><code>123
</code></pre>


<h2>Skipping members</h2>

Use the <code>[FleXMLer]</code> annotation with the <code>skip</code> option to specify a certain should not be serialized, deserialized or both.<br>

The following code:<br>
<pre><code>public class Skip
{
	[FleXMLer(skip = "serialize")]		
	public var dontSerialize:String;
		
	[FleXMLer(skip = "deserialize")]
	public var dontDeserialize:String;
		
	[FleXMLer(skip = "always")]
	public var dont:String;
}
</code></pre>
<pre><code>var s:Skip = new Skip();
s.dontSerialize = "qwe";
s.dontDeserialize = "asd";
s.dont = "zxc";
			
trace(new FleXMLer().serialize(s));
</code></pre>

Produces:<br>
<pre><code>&lt;Skip&gt;
  &lt;dontDeserialize&gt;asd&lt;/dontDeserialize&gt;
&lt;/Skip&gt;
</code></pre>

And the following:<br>
<pre><code>var s:Skip = new FleXMLer().deserialize(
	&lt;Skip&gt;
		&lt;dontSerialize&gt;123&lt;/dontSerialize&gt;
		&lt;dontDeserialize&gt;456&lt;/dontDeserialize&gt;
		&lt;dont&gt;456&lt;/dont&gt;
	&lt;/Skip&gt;
	) as Skip;
					
trace(s.dontSerialize);
trace(s.dontDeserialize);
trace(s.dont);			
</code></pre>
Produces:<br>
<pre><code>123
null
null
</code></pre>

<h2>Specifying Serialization Instructions Programmatically</h2>
Default seriazation uses reflection to iterate the type's members.<br>
As an alternative, you can specify the serialization information programmatically at runtime in the form of an associative array object.<br>
The object should have the following structure:<br>
<code>{ propertyName : { settingName : settingValue } }</code><br>
Use <code>"/"</code> as <code>propertyName</code> to specify class-level information.<br>
<br>
Default serialization creates XML elements. <br>
Use the <code>[FleXMLer]</code> annotation with the <code>attribute</code> option to specify value should be serialized as an attribute.<br>
The default attribute name is the variable name.<br>
<br>
For the following class:<br>
<pre><code>public class WithProgrammaticalSerializationInfo
{
	public var i:int = 123;
	public var s:String = "abc";
}
</code></pre>
Default serialization would be as follows:<br>
<pre><code>&lt;WithProgrammaticalSerializationInfo&gt;
  &lt;i&gt;123&lt;/i&gt;
  &lt;s&gt;abc&lt;/s&gt;
&lt;/WithProgrammaticalSerializationInfo&gt;
</code></pre>

While the following code:<br>
<pre><code>var obj:WithProgrammaticalSerializationInfo = new WithProgrammaticalSerializationInfo();
var serInfo:XML = {
			"/" : { "alias" : "wps" },
			"i" : { "skip" : "serialize" },
			"s" : { "alias" : "str" }
		}

trace(new FleXMLer().serialize(obj, serInfo));
</code></pre>

Produces:<br>
<pre><code>&lt;wps&gt;
  &lt;str&gt;abc&lt;/str&gt;
&lt;/wps&gt;
</code></pre>