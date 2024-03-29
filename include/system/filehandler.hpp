#pragma once

#include <vector>
#include <string>
#include <map>
#include <fstream>
#include <iostream>
#include "cuda/cuda_complex.cuh"

namespace PC3 {

class FileHandler {
   public:
    std::map<std::string, std::ofstream> files;
    std::string outputPath, loadPath, outputName, color_palette, color_palette_phase;

    bool disableRender;

    FileHandler();
    FileHandler( int argc, char** argv);
    FileHandler( FileHandler& other ) = delete;

    struct Header {
        real_number s_L_x, s_L_y;
        real_number dx, dy;
        real_number t;
        Header() : s_L_x( 0 ), s_L_y( 0 ), dx( 0 ), dy( 0 ), t( 0 ) {}
        Header( real_number s_L_x, real_number s_L_y, real_number dx, real_number dy, real_number t ) : Header() {
            this->s_L_x = s_L_x;
            this->s_L_y = s_L_y;
            this->dx = dx;
            this->dy = dy;
            this->t = t;
        }
        friend std::ostream& operator<<( std::ostream& os, const Header& header ) {
            os << "LX " << header.s_L_x << " LY " << header.s_L_y << " DX " << header.dx << " DY " << header.dy << " TIME " << header.t;
            return os;
        }
    };

    std::string toPath( const std::string& name );

    std::ofstream& getFile( const std::string& name );

    void loadMatrixFromFile( const std::string& filepath, complex_number* buffer );
    void loadMatrixFromFile( const std::string& filepath, real_number* buffer );

    void outputMatrixToFile( const complex_number* buffer, unsigned int col_start, unsigned int col_stop, unsigned int row_start, unsigned int row_stop, const unsigned int N_x, const unsigned int N_y, unsigned int increment, const Header& header, std::ofstream& out, const std::string& name );
    void outputMatrixToFile( const complex_number* buffer, unsigned int col_start, unsigned int col_stop, unsigned int row_start, unsigned int row_stop, const unsigned int N_x, const unsigned int N_y, unsigned int increment, const Header& header, const std::string& out );
    void outputMatrixToFile( const complex_number* buffer, const unsigned int N_x, const unsigned int N_y, const Header& header, const std::string& out );
    void outputMatrixToFile( const complex_number* buffer, const unsigned int N_x, const unsigned int N_y, const Header& header, std::ofstream& out, const std::string& name );

    void outputMatrixToFile( const real_number* buffer, unsigned int col_start, unsigned int col_stop, unsigned int row_start, unsigned int row_stop, const unsigned int N_x, const unsigned int N_y, unsigned int increment, const Header& header, std::ofstream& out, const std::string& name );
    void outputMatrixToFile( const real_number* buffer, unsigned int col_start, unsigned int col_stop, unsigned int row_start, unsigned int row_stop, const unsigned int N_x, const unsigned int N_y, unsigned int increment, const Header& header, const std::string& out );
    void outputMatrixToFile( const real_number* buffer, const unsigned int N_x, const unsigned int N_y, const Header& header, const std::string& out );
    void outputMatrixToFile( const real_number* buffer, const unsigned int N_x, const unsigned int N_y, const Header& header, std::ofstream& out, const std::string& name );
    
    void init( int argc, char** argv );
};

} // namespace PC3