#!/usr/bin/perl

# bjcp2html.pl
# Autor: Luis Balbinot <hades.himself@gmail.com>
#
# Processa o arquivo XML das Diretrizes de Estilo BJCP e 
# gera um HTML bastante simples para stdout.

use XML::LibXML;
use HTML::StripTags qw(strip_tags);

my $parser = XML::LibXML->new();
my $doc = $parser->parse_file("styleguide2008_pt.xml");

binmode STDOUT, ":utf8";
print "<html>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n";

foreach my $category ($doc->findnodes('/styleguide/class/category')) {
	# Aqui estah no nivel das categorias
	my $name = $category->findnodes('./name');
	my $id = $category->findnodes('@id');
	print "<h2>", $id->to_literal, ". ", $name->to_literal, "</h2>\n";
	my $translated = $category->findnodes('./name/@translated');
	print "<h2><em>", $translated->to_literal, "</em></h2>\n" if ($translated);

	# Aqui estah dentro de subcategorias
	foreach my $subcategory ($category->findnodes('./subcategory')) {
		my $name = $subcategory->findnodes('./name');
		my $id = $subcategory->findnodes('@id');
		print "<h3>", $id, ". ", $name->to_literal, "</h3>\n";
		my $translated = $subcategory->findnodes('./name/@translated');
		print "<h3><em>", $translated->to_literal, "</em></h3>\n" if ($translated);
		print_items($subcategory);
	}
}

print "</html>\n";

sub print_items() {
	my $category = shift;
	my $item;
	foreach my $node ($category->findnodes('./*')) {
		$item = undef;
		if ($node->nodeName eq "stats") {
			if (my $exceptions = $node->findnodes('./exceptions')) {
				print "<p><strong>Estat&iacute;sticas:</strong> ";
				print strip_tags($exceptions->[0]->serialize, "<em><strong><ul><li>");
				print "</p>\n";
			} else {
				foreach my $stat ($node->findnodes('./*/*')) {
					my $temp = $stat->to_literal;
					$temp =~ s/\,/./;
					if (($stat->parentNode->nodeName eq "srm") ||
					    ($stat->parentNode->nodeName eq "abv")) {
					    $temp *= 1;
					}
					$temp =~ s/\./,/;
					$stats{$stat->parentNode->nodeName}{$stat->nodeName} = $temp;
				}
				print "<p><strong>Estat&iacute;sticas:</strong>\t";
				print "OG: ", $stats{'og'}{'low'} ," - ", $stats{'og'}{'high'},"<br>\n";
				print "IBUs: ", $stats{'ibu'}{'low'} ," - ", $stats{'ibu'}{'high'},"\t";
				print "FG: ", $stats{'fg'}{'low'} ," - ", $stats{'fg'}{'high'},"<br>\n";
				print "SRMs: ", $stats{'srm'}{'low'} ," - ", $stats{'srm'}{'high'},"\t";
				print "ABV: ", $stats{'abv'}{'low'} ," - ", $stats{'abv'}{'high'}, "%\n";
				print "</p>\n";
			}
		} elsif ($node->nodeName eq "notes") {
			print "<p>";
			print strip_tags($node->serialize, "<em><strong><ul><li>");
			print "</p>\n";
		} else {
			$item = "Aroma" if ($node->nodeName eq "aroma");
			$item = "Apar&ecirc;ncia" if ($node->nodeName eq "appearance");
			$item = "Sabor" if ($node->nodeName eq "flavor");
			$item = "Sensa&ccedil;&atilde;o na Boca" if ($node->nodeName eq "mouthfeel");
			$item = "Impress&atilde;o Geral" if ($node->nodeName eq "impression");
			$item = "Coment&aacute;rios" if ($node->nodeName eq "comments");
			$item = "Ingredientes" if ($node->nodeName eq "ingredients");
			$item = "Exemplos Comerciais" if ($node->nodeName eq "examples");
			if ($item) {
				print "<p><strong>", $item, ":</strong> ";
				print strip_tags($node->serialize, "<em><strong><ul><li>");
				print "</p>\n";
			}
		}
	}
}

