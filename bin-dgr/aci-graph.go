package main

import (
	"bytes"
	"github.com/n0rad/go-erlog/errs"
	"github.com/n0rad/go-erlog/logs"
	"io/ioutil"
	"os"
)

func (aci *Aci) Graph() error {
	defer aci.giveBackUserRightsToTarget()
	logs.WithF(aci.fields).Debug("Graphing")

	os.MkdirAll(aci.target, 0777)

	var buffer bytes.Buffer
	buffer.WriteString("digraph {\n")

	for _, dep := range aci.manifest.Aci.Dependencies {
		buffer.WriteString("  ")
		buffer.WriteString("\"")
		buffer.WriteString(dep.ShortNameId())
		buffer.WriteString("\"")
		buffer.WriteString(" -> ")
		buffer.WriteString("\"")
		buffer.WriteString(aci.manifest.NameAndVersion.ShortNameId())
		buffer.WriteString("\"")
		buffer.WriteString("\n")
	}

	buffer.WriteString("}\n")

	if err := ioutil.WriteFile(aci.target+PATH_GRAPH_DOT, buffer.Bytes(), 0644); err != nil {
		return errs.WithEF(err, aci.fields.WithField("file", aci.target+PATH_GRAPH_DOT), "Failed to write file")
	}

	return nil
}