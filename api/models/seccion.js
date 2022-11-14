/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('seccion', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_coleccion: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'coleccion',
				key: 'nombre'
			}
		},
		id_seccion: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_seccion::regclass)",
			primaryKey: true
		}
	}, {
		tableName: 'seccion',
		timestamps: false
	});
};
