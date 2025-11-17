#!/usr/bin/perl

use warnings;
use strict;

my $in0 = $ARGV[0]; ##- readMapped.regions.Lst
my $out = $ARGV[1]; ##- output

my %index = ();

open IN0, $in0;
while(<IN0>){
	chomp;
	my @temp = split(/\t/, $_);
	my ($a, $b, $c, $l, $r) = (0, 0, 0, 0, 0);
	for(my $m=3; $m<=$#temp; $m++){
# 清理多余的空格，确保匹配
	my $entry = $temp[$m];
	$entry =~ s/\s+//g;  # 去除多余的空格

		if($entry eq "aa"){
		$a += 1;
		}
		if($entry eq "bb"){
		$b += 1;
		}
		if($entry eq "cc"){
		$c += 1;
		}
		if($entry eq "ab"){
		$l += 1;
		}
	if($entry eq "bc"){
	$r += 1;
		}
	}  

# 初始化标志
my ($AB, $BC, $AC, $L, $R) = ("-", "-", "-", "-", "-");  
# 根据计数情况设置标志
$AB = "Y" if($a > 0 && $b > 0);
$BC = "Y" if($b > 0 && $c > 0);
$AC = "Y" if($a > 0 && $c > 0); 
$L  = "Y" if($l > 0);
$R  = "Y" if($r > 0);

# 将结果保存到哈希表中
$index{$temp[1]}{$temp[0]} = "$AB\t$BC\t$AC\t$L\t$R";
}
close IN0;

open OUTXXX, ">$out";
print OUTXXX join("\t", "TEindex", "AB", "BC", "AC", "L", "R", "Genotype"), "\n";
for my $key1 (sort keys %index){
my %value = ();
for my $readid (keys %{$index{$key1}}){
	my @info = split("\t", $index{$key1}{$readid}); 
	for(my $m = 0; $m <= $#info; $m++){
	$value{$m} += 1 if($info[$m] eq "Y");
	}
}

# 结果数组
my @values = ();
for(my $n = 0; $n <= 4; $n++){
	my $flag = 0;
	$flag = $value{$n} if(exists $value{$n});
	push(@values, $flag);
}

# 计算差异和一致性
my $diff = $values[0] + $values[1] + $values[3] + $values[4];
my $consist = $values[2];
my $geno = "NA";

$geno = "CC" if($consist > 0 && $diff == 0);
$geno = "GG" if($consist == 0 && $diff > 0); 
$geno = "CG" if($consist > 0 && $diff > 0);

# 输出结果
print OUTXXX join("\t", $key1, @values, $geno), "\n"; 
}
close OUTXXX;

