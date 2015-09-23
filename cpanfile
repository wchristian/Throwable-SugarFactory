requires "Class::Inspector" => "0";
requires "Exporter" => "0";
requires "Import::Into" => "0";
requires "Module::Runtime" => "0";
requires "Moo::Role" => "0";
requires "Package::Variant" => "1.003002";
requires "String::CamelCase" => "0";
requires "Throwable" => "0";
requires "parent" => "0";
requires "perl" => "5.006";
requires "strict" => "0";
requires "strictures" => "2";

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Moo" => "0";
  requires "Test::Fatal" => "0";
  requires "Test::InDistDir" => "0";
  requires "Test::More" => "0";
  requires "Try::Tiny" => "0";
  requires "perl" => "5.006";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "perl" => "5.006";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::More" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Version" => "1";
};
