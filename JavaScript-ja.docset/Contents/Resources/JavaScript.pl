$relativeInside = "developer.mozilla.org/ja/";
$relativePath = "Documents/".$relativeInside;
$domFolderPath = $relativePath."docs/DOM/";
$jsFolderPath = $relativePath."docs/Web/JavaScript/Reference";

use HTML::TagParser;
use File::Find;
$| = 1;

open(TOKENS, ">Tokens.xml");
print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

$dom = HTML::TagParser->new();
$dom->open("Documents/developer.mozilla.org/ja/docs/DOM/DOM_Reference.html");
$title = $dom->getElementById("title");

find( \&parseHTML, $domFolderPath);
find( \&parseHTML, $jsFolderPath);

print TOKENS "</Tokens>";
close(TOKENS);

sub parseHTML
{
  if(/\.html$/)
  {
    $file = "$File::Find::name$/";
    chomp($file);
    $dom = HTML::TagParser->new();
    $dom->open("/Users/fainder/Downloads/dash-docsets-master/Docsets/JavaScript-ja.docset/Contents/Resources/".$file);
    $title = $dom->getElementById("title");
    $type = "cl";
    @components = split(/\//, $file);
    if(($components[$components-3] =~ /Global_Objects/ || $components[$components-3] =~ /Functions_and_function_scope/ || ($components[$components-3] =~ /DOM/ && !($components[$components-2] =~ /_/) && ucfirst($title) ne $title)) && !($title =~ /$components[$components-2]\./))
    {
      $title = $components[$components-2].".".$title;
    }
    if($title =~ / /)
    {
      return;
    }
    if($title =~ /\./ && !($title =~ /\.\./))
    {
      $type = "clm";
    }
    elsif($file =~ /\/Global_Objects\// && lcfirst($title) eq $title)
    {
      if($title =~ /undefined/)
      {
        $type = "cl";
      }
      else
      {
        $type = "func";
      }
    }
    if($file =~ /\/Operators\// || $file =~ /\/Statements\//)
    {
      $type = "func";
    }
    if(!grep {$_ eq $title} @ADDED) 
    {
      $ADDED[++$#ADDED] = $title;
    }
    else
    {
      print "DUPLICATE FOUND FOR $title at $file\n";
      return;
    }
    print $title." -> $type\n";
    $file =~ s/Documents\///;
    print TOKENS "<File path=\"".$file."\"><Token><TokenIdentifier>//apple_ref/cpp/".$type."/".$title."</TokenIdentifier></Token></File>\n";
  }
}
