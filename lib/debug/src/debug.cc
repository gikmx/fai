
#include <node.h>
#include <v8.h>
#include <v8-profiler.h>

#include <cstdio>

using namespace v8;

class FileOutputStream: public OutputStream {
	private:
		FILE* stream_;

	public:
		FileOutputStream(FILE* stream): stream_(stream){}

		virtual int GetChunkSize(){
			return 65536; // BIG chunk == fast
		}

		virtual void EndOfStream(){}

		virtual WriteResult WriteAsciiChunk(char* data, int size){
			const size_t len = static_cast<size_t>(size);
			size_t off = 0;
			while (off < len && !feof(stream_) && !ferror(stream_))
				off += fwrite(data + off, 1, len - off, stream_);
			return off == len ? kContinue : kAbort;
		}
};

Handle<Value> Write(const Arguments& args) {
	HandleScope scope;
	char filename[512];
	char *name, *path;

	if (args.Length() < 2){
		ThrowException(Exception::TypeError(String::New("Expecting two arguments.")));
		return scope.Close(Undefined());
	}

	if (!args[0]->IsString()){
		ThrowException(Exception::TypeError(String::New("Expecting 'path' argument.")));
		return scope.Close(Undefined());
	}


	if (!args[1]->IsString()){
		ThrowException(Exception::TypeError(String::New("Expecting 'name' argument.")));
		return scope.Close(Undefined());
	}

	String::Utf8Value param0(args[0]->ToString());
	path = *param0;

	String::Utf8Value param1(args[1]->ToString());
	name = *param1;

	std::snprintf(filename, sizeof(filename), "%s/%s.heapsnapshot", path, name);
	FILE* fp = fopen(filename,"w");
	if (fp == NULL) {
		ThrowException(Exception::TypeError(String::New("Could not write HeapSnapshot")));
		return scope.Close(Undefined());
	}

	const HeapSnapshot* snap= HeapProfiler::TakeSnapshot(String::Empty());
	FileOutputStream stream(fp);
	snap->Serialize(&stream, HeapSnapshot::kJSON);
	fclose(fp);
	return scope.Close(Undefined());
};

void init(Handle<Object> handle) {
	handle->Set(String::NewSymbol("write"), FunctionTemplate::New(Write)->GetFunction());
};

NODE_MODULE(debug, init);
