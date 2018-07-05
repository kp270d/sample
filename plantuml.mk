# plantuml.mk -- GNU Make utilities to generate PlanUML diagrams
#
# See https://rndwiki.corp.hpicorp.net/confluence/display/IPGCTO/CWP+-+Using+PlantUML
# See https://gist.github.azc.ext.hp.com/francois-xavier-kowalski/db56a5cf7aaa750c6c3969baf367b707

default: png

# commands

PLANTUML := $(shell which plantuml 2>/dev/null || echo false)
ifeq ($(PLANTUML),false)

#PLANTUML_JAR = $(HOME)/lib/plantuml.jar
PLANTUML_JAR := /usr/share/plantuml/plantuml.jar
ifneq ($(Apple_PubSub_Socket_Render),)
PLANTUML_JAR := /usr/local/Cellar/plantuml/8053/libexec/plantuml.jar
endif
ifeq ($(OS),Windows_NT)
PLANTUML_JAR := "C:\ProgramData\chocolatey\lib\plantuml\tools\plantuml.jar"
endif
$(info using PLANTUML_JAR=$(PLANTUML_JAR))

GRAPHVIZ_DOT := $(shell which dot 2>/dev/null || echo false)
ifeq ($(GRAPHVIZ_DOT),false)
ifeq ($(OS),Windows_NT)
GRAPHVIZ_DOT := "C:\Program Files (x86)\Graphviz2.38\bin\dot.exe"
endif
endif
$(info using GRAPHVIZ_DOT=$(GRAPHVIZ_DOT))

JAVA = $(shell which java || echo false)
PLANTUML = $(JAVA) -jar $(PLANTUML_JAR) -charset UTF-8 -v -graphvizdot $(GRAPHVIZ_DOT)
endif
$(info using PLANTUML=$(PLANTUML))

INKSCAPE := $(shell which inkscape 2>/dev/null || echo false)
ifeq ($(INKSCAPE),false)
ifneq ($(Apple_PubSub_Socket_Render),)
INKSCAPE := /Applications/Inkscape.app/Contents/Resources/bin/inkscape
endif
ifeq ($(OS),Windows_NT)
INKSCAPE := "C:\Program Files (x86)\Inkscape\inkscape.exe"
endif
endif

$(info using INKSCAPE=$(INKSCAPE))

RM = rm -fv

# produces PNG files

DIAGRAMS_PNG = $(DIAGRAMS:.puml=.png)

png: $(DIAGRAMS_PNG)

%.png: %.puml
	$(PLANTUML) "$(*).puml" -png

# produces SVG files

DIAGRAMS_SVG = $(DIAGRAMS:.puml=.svg)

svg: $(DIAGRAMS_SVG)

%.svg: %.puml
	$(PLANTUML) "$(*).puml" -svg

# produces PDF files -- see http://plantuml.com/pdf

DIAGRAMS_PDF = $(DIAGRAMS:.puml=.pdf)

pdf: $(DIAGRAMS_PDF)

#%.pdf: %.puml
#	$(PLANTUML) "$(*).puml" -pdf

%.pdf: %.svg
	$(INKSCAPE) --without-gui --file="$(CURDIR)/$(*).svg" --export-pdf="$(CURDIR)/$(*).pdf"

# cleanup

clean:
	$(RM) $(DIAGRAMS_PDF) $(DIAGRAMS_PNG) $(DIAGRAMS_SVG)
