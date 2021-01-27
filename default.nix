with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "diffyq";

  src = ./src;

  buildInputs = [ exiftool html-tidy pandoc rsync ];

  buildPhase = ''
    md2html() {
        in_file=$1
        out_file=$(sed 's/^root/out/;s/\.html\.md$/.html/' <<< $in_file)

        http_path=$(sed 's/^out//;s/index.html$//' <<< $out_file)

        pandoc --from=markdown+smart --template=template.html \
            --shift-heading-level-by 2 -M http_path:$http_path \
            $in_file | tidy -w 0 --drop-empty-elements no -q > $out_file
    }

    rsync -lqr --exclude="*.html.md" root/ out/

    find root -print0 | \
        while IFS= read -r -d "" in_file; do
            if [[ $in_file == *.html.md ]]; then
                md2html $in_file
            fi
        done

    exiftool -r -overwrite_original -all= out/
  '';

  installPhase = ''
    rsync -lqr out/ $out/
  '';
}
