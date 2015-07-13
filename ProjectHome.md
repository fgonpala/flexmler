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
<pre><code>// serialize object to XML<br>
var xml:XML = new FleXMLer().serialize(obj);<br>
<br>
// deserialize XML to Object<br>
var obj:MyType = new FleXMLer().deserialize(xmlobject[, MyType]);<br>
</code></pre>

<b>Note:</b> If you use need to use the <code>[FleXMLer]</code> annotation, be sure to add the following compilation switch:<br>
<pre><code>-keep-as3-metadata+=FleXMLer<br>
</code></pre>



<h2>Basic Serialization</h2>
Basic serialization supports all primitive types, and has special treatment for arrays and generic object hash tables.<br>
<br>
The following code:<br>
<pre><code>public class Basic<br>
{<br>
	public var name:String = "str";<br>
	public var num:Number = 123.456;<br>
	public var bool:Boolean = true;<br>
	public var date:Date = new Date("Sat Feb 3 04:05:06 GMT-0500 2001");<br>
	public var arr:Array = [123, "qwe", null, false];<br>
	public var hash:Object = { 123 : true, "qwe" : new Date("Sat Feb 3 04:05:06 GMT-0500 2001") };<br>
<br>
	private var _acc:Number;<br>
		<br>
	public function set acc(val:Number):void { _acc = val;  }<br>
	public function get acc():Number { return _acc; }<br>
}<br>
</code></pre>
<pre><code>var b:Basic = new Basic();<br>
b.acc = 987.65;<br>
trace((new FleXMLer().serialize(b)).toXMLString());<br>
</code></pre>

Produces:<br>
<br>
<pre><code>&lt;Basic&gt;<br>
  &lt;name&gt;str&lt;/name&gt;<br>
  &lt;num&gt;123.456&lt;/num&gt;<br>
  &lt;date&gt;Sat Feb 3 11:05:06 GMT+0200 2001&lt;/date&gt;<br>
  &lt;bool&gt;true&lt;/bool&gt;<br>
  &lt;acc&gt;123.345&lt;/acc&gt;<br>
  &lt;arr&gt;<br>
    &lt;String&gt;123&lt;/String&gt;<br>
    &lt;String&gt;qwe&lt;/String&gt;<br>
    &lt;null/&gt;<br>
    &lt;Boolean&gt;false&lt;/Boolean&gt;<br>
  &lt;/arr&gt;<br>
  &lt;hash&gt;<br>
    &lt;entry&gt;<br>
      &lt;key&gt;<br>
        &lt;String&gt;qwe&lt;/String&gt;<br>
      &lt;/key&gt;<br>
      &lt;val&gt;<br>
        &lt;Date&gt;Sat Feb 3 11:05:06 GMT+0200 2001&lt;/Date&gt;<br>
      &lt;/val&gt;<br>
    &lt;/entry&gt;<br>
    &lt;entry&gt;<br>
      &lt;key&gt;<br>
        &lt;int&gt;123&lt;/int&gt;<br>
      &lt;/key&gt;<br>
      &lt;val&gt;<br>
        &lt;Boolean&gt;true&lt;/Boolean&gt;<br>
      &lt;/val&gt;<br>
    &lt;/entry&gt;<br>
  &lt;/hash&gt;<br>
&lt;/Basic&gt;<br>
</code></pre>

<h2>Nested Objects</h2>

Nested objects are handled by default as well.<br>
The following code:<br>
<pre><code>public class Nestee<br>
{<br>
	public var num:Number = 1.23;<br>
}<br>
</code></pre>
<pre><code>public class Nester<br>
{<br>
	public var str:String = "asd";<br>
	public var n:Nestee = new Nestee();<br>
}<br>
</code></pre>
Produces:<br>
<pre><code>&lt;Nester&gt;<br>
  &lt;str&gt;asd&lt;/str&gt;<br>
  &lt;Nestee&gt;<br>
    &lt;num&gt;1.23&lt;/num&gt;<br>
  &lt;/Nestee&gt;<br>
&lt;/Nester&gt;<br>
</code></pre>

<h2>Serializing as attribute</h2>
Default serialization creates XML elements. <br>
Use the <code>[FleXMLer]</code> annotation with the <code>attribute</code> option to specify value should be serialized as an attribute.<br>
The default attribute name is the variable name.<br>
You can supply a string to be used as an attribute name.<br>
<pre><code>public class Attributes<br>
{<br>
	[FleXMLer(attribute)]<br>
	public var att1:String = "val1";<br>
	[FleXMLer(attribute=xxx)]<br>
	public var att2:String = "val2";<br>
}<br>
</code></pre>

Produces:<br>
<br>
<pre><code>&lt;Attributes att1="val1" xxx="val2"/&gt;<br>
</code></pre>

<h2>Aliasing</h2>
Default serialization uses the class or variable name for the XML element name. <br>
Use the <code>[FleXMLer]</code> annotation with the <code>alias</code> option to specify an alternative element name.<br>
<pre><code>[FleXMLer(alias="type_alias")]<br>
public class Aliasing<br>
{<br>
	[FleXMLer(alias="var_alias")]<br>
	public var name:String = "str";<br>
}<br>
</code></pre>

Produces:<br>
<br>
<pre><code>&lt;type_alias&gt;<br>
  &lt;var_alias&gt;str&lt;/var_alias&gt;<br>
&lt;/type_alias&gt;<br>
</code></pre>

<b>Note:</b> XML element name is used in deserialization as the type of the object to create. <br>
If you modify the class element name, you must explicitly specify the type in the call to the <code>deserialize</code> method.<br>
<br>
<h2>Aliasing array members</h2>

Default serialization of array members uses the member class name for the XML element name.<br>
Use the <code>[FleXMLer]</code> annotation with the <code>memberAlias</code> option to specify an alternative element name.<br>
Since XML element name is used in deserialization as the type of the object to create, you must also specify the member type in the annotation using the <code>memberType</code> option.<br>
Naturally, this requires all array members to be of the same type.<br>
<pre><code>public class ArrayAliasing<br>
{		<br>
	[FleXMLer(memberAlias="num",memberType="Number")]<br>
	public var arr:Array = [ 1.23, 2.34, null, 3.45 ];<br>
}<br>
</code></pre>
Produces:<br>
<pre><code>&lt;ArrayAliasing&gt;<br>
  &lt;arr&gt;<br>
    &lt;num&gt;1.23&lt;/num&gt;<br>
    &lt;num&gt;2.34&lt;/num&gt;<br>
    &lt;null/&gt;<br>
    &lt;num&gt;3.45&lt;/num&gt;<br>
  &lt;/arr&gt;<br>
&lt;/ArrayAliasing&gt;<br>
<br>
</code></pre>

<h2>Objects (Hash Tables)</h2>

Serialization of object hash members uses the following format by default:<br>
<pre><code>&lt;entry&gt;<br>
  &lt;key&gt;<br>
    &lt;key1Type&gt;key1&lt;/key1Type&gt;<br>
  &lt;/key&gt;<br>
  &lt;value&gt;<br>
    &lt;value1Type&gt;value1&lt;/value1Type&gt;<br>
  &lt;/value&gt;<br>
&lt;/entry&gt;<br>
&lt;entry&gt;<br>
  &lt;key&gt;<br>
    &lt;key2Type&gt;key2&lt;/key2Type&gt;<br>
  &lt;/key&gt;<br>
  &lt;value&gt;<br>
    &lt;value2Type&gt;value2&lt;/value2Type&gt;<br>
  &lt;/value&gt;<br>
&lt;/entry&gt;<br>
</code></pre>

You can change the names of any of the entry, key, or value XML element name using the <code>[FleXMLer]</code> annotation with the <code>entryAlias</code>, <code>keyAlias</code>, and <code>valueAlias</code> correspondingly.<br>
<pre><code>public class Hash<br>
{<br>
	[FleXMLer(entryAlias="e",keyAlias="k",valueAlias="v")]<br>
	public var h:Object = { 1 : "qwe", 3 : "wer" };<br>
}<br>
</code></pre>
Produces:<br>
<pre><code>&lt;Hash&gt;<br>
  &lt;h&gt;<br>
    &lt;e&gt;<br>
      &lt;k&gt;<br>
        &lt;int&gt;1&lt;/int&gt;<br>
      &lt;/k&gt;<br>
      &lt;v&gt;<br>
        &lt;String&gt;qwe&lt;/String&gt;<br>
      &lt;/v&gt;<br>
    &lt;/e&gt;<br>
    &lt;e&gt;<br>
      &lt;k&gt;<br>
        &lt;int&gt;3&lt;/int&gt;<br>
      &lt;/k&gt;<br>
      &lt;v&gt;<br>
        &lt;String&gt;wer&lt;/String&gt;<br>
      &lt;/v&gt;<br>
    &lt;/e&gt;<br>
  &lt;/h&gt;<br>
&lt;/Hash&gt;<br>
</code></pre>

Specifying a fixed type name for keys and/or values using the <code>keyType</code> and <code>valueType</code> options will generate XML without the type names.<br>
<br>
<pre><code>public class Hash<br>
{<br>
	[FleXMLer(keyType="Number",valueType="Boolean")]<br>
	public var h2:Object = { 1.23 : true, 3.45 : false };<br>
}<br>
</code></pre>
Produces:<br>
<pre><code>&lt;hash&gt;<br>
  &lt;h2&gt;<br>
    &lt;entry&gt;<br>
      &lt;key&gt;3.45&lt;/key&gt;<br>
      &lt;value&gt;false&lt;/value&gt;<br>
    &lt;/entry&gt;<br>
    &lt;entry&gt;<br>
      &lt;key&gt;1.23&lt;/key&gt;<br>
      &lt;value&gt;true&lt;/value&gt;<br>
    &lt;/entry&gt;<br>
  &lt;/h2&gt;<br>
&lt;/hash&gt;<br>
</code></pre>

An ever more concise XML can be generated for hashes using the <code>keyAsElementName</code> option (requires <code>keyType="String"</code>).<br>
<pre><code>public class Hash<br>
{<br>
	[FleXMLer(keyType="String",valueType="Number",keyAsElementName="true")]<br>
	public var h3:Object = { "qweqwe" : 1.234, "zxczxczc" : 9.876 };<br>
}<br>
</code></pre>
Produces:<br>
<pre><code>&lt;Hash&gt;<br>
  &lt;h3&gt;<br>
    &lt;zxczxczc&gt;9.876&lt;/zxczxczc&gt;<br>
    &lt;qweqwe&gt;1.234&lt;/qweqwe&gt;<br>
  &lt;/h3&gt;<br>
&lt;/Hash&gt;<br>
</code></pre>



<h2>Specifying default values</h2>

Use the <code>[FleXMLer]</code> annotation with the <code>default</code> option to specify a default value to use in deserialization if a variable was not specified.<br>
This option can only apply to 'primitive' types (int, Number, Boolean, String, Date).<br>

The following code:<br>
<pre><code>public class Default<br>
{<br>
	[FleXMLer(default = "123")]	<br>
	public var num:int;<br>
}<br>
</code></pre>

<pre><code>  var d:Default = new FleXMLer().deserialize(&lt;Default/&gt;);<br>
  trace(d.num.toString());<br>
</code></pre>

Produces:<br>
<pre><code>123<br>
</code></pre>


<h2>Skipping members</h2>

Use the <code>[FleXMLer]</code> annotation with the <code>skip</code> option to specify a certain should not be serialized, deserialized or both.<br>

The following code:<br>
<pre><code>public class Skip<br>
{<br>
	[FleXMLer(skip = "serialize")]		<br>
	public var dontSerialize:String;<br>
		<br>
	[FleXMLer(skip = "deserialize")]<br>
	public var dontDeserialize:String;<br>
		<br>
	[FleXMLer(skip = "always")]<br>
	public var dont:String;<br>
}<br>
</code></pre>
<pre><code>var s:Skip = new Skip();<br>
s.dontSerialize = "qwe";<br>
s.dontDeserialize = "asd";<br>
s.dont = "zxc";<br>
			<br>
trace(new FleXMLer().serialize(s));<br>
</code></pre>

Produces:<br>
<pre><code>&lt;Skip&gt;<br>
  &lt;dontDeserialize&gt;asd&lt;/dontDeserialize&gt;<br>
&lt;/Skip&gt;<br>
</code></pre>

And the following:<br>
<pre><code>var s:Skip = new FleXMLer().deserialize(<br>
	&lt;Skip&gt;<br>
		&lt;dontSerialize&gt;123&lt;/dontSerialize&gt;<br>
		&lt;dontDeserialize&gt;456&lt;/dontDeserialize&gt;<br>
		&lt;dont&gt;456&lt;/dont&gt;<br>
	&lt;/Skip&gt;<br>
	) as Skip;<br>
					<br>
trace(s.dontSerialize);<br>
trace(s.dontDeserialize);<br>
trace(s.dont);			<br>
</code></pre>
Produces:<br>
<pre><code>123<br>
null<br>
null<br>
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
<pre><code>public class WithProgrammaticalSerializationInfo<br>
{<br>
	public var i:int = 123;<br>
	public var s:String = "abc";<br>
}<br>
</code></pre>
Default serialization would be as follows:<br>
<pre><code>&lt;WithProgrammaticalSerializationInfo&gt;<br>
  &lt;i&gt;123&lt;/i&gt;<br>
  &lt;s&gt;abc&lt;/s&gt;<br>
&lt;/WithProgrammaticalSerializationInfo&gt;<br>
</code></pre>

While the following code:<br>
<pre><code>var obj:WithProgrammaticalSerializationInfo = new WithProgrammaticalSerializationInfo();<br>
var serInfo:XML = {<br>
			"/" : { "alias" : "wps" },<br>
			"i" : { "skip" : "serialize" },<br>
			"s" : { "alias" : "str" }<br>
		}<br>
<br>
trace(new FleXMLer().serialize(obj, serInfo));<br>
</code></pre>

Produces:<br>
<pre><code>&lt;wps&gt;<br>
  &lt;str&gt;abc&lt;/str&gt;<br>
&lt;/wps&gt;<br>
</code></pre>